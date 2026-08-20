---
description: Benchmark a llama.cpp preset and tune it one knob at a time
argument-hint: "[preset-id]"
---

Run the interactive llama.cpp preset tuning wizard. You are operating on the
user's dotfiles repo, which is a git checkout managed by RCM. This workflow
modifies the repo and the live local router, so be careful and ask before
every mutation.

## Environment checks (do these first, before asking anything)

1. Verify the working directory is the dotfiles repo and that it is writable
   (the `ppi` workspace mount, not read-only):

   `git rev-parse --show-toplevel` must equal `$HOME/.dotfiles`. If it is
   anything else, tell the user: "Run this from the dotfiles repo:
   `cd ~/.dotfiles && ppi`" and stop.

2. Verify the router is reachable: `curl -s http://127.0.0.1:10999/health`
   must return `{"status":"ok"}`. If not, tell the user the router is down
   and stop; do not start it yourself.

3. Locate the files you will use:

   - Presets:           `tag-ai/config/llama-cpp/preset.ini`
   - Benchmark script:  `tag-ai/local/bin/llama-cpp-benchmark`
   - Transactional sweep helper (read-only reference for how edits/reloads
     are done safely): `tag-ai/local/bin/llama-cpp-bench-draft`

## Read and understand first

4. Read the preset file completely. Enumerate every `[section]` and its
   keys/values — these are the presets available for tuning.

5. Read the benchmark script's header comment and `usage()` so you know its
   contract:

   - `--fast` (default): 5 fixed sizes, cold-only, 2 runs, 256 decode,
     gate at 32k/2. Fast triage, ~5-7 min.
   - `--full`: sizes derived from the preset's n_ctx, warm+cold, 3 runs,
     1024 decode, gate at capacity. Acceptance, 25-45 min depending on
     preset.
   - Overridable flags: `--runs`, `--sizes`, `--mode cold|warm|both`,
     `--decode-tokens`, `--gate-context`, `--gate-runs`, `--exclusive`.
   - Output is a single JSON document (schema v2) with `results`, `raw_runs`,
     `memory`, `gates`, `capacity_ceiling`, `skipped_sizes`.

## Ask before running (one focused question at a time)

6. Ask which preset to tune. Present the list from step 4 if the preset id
   was not given as the template argument. Confirm you will benchmark the
   *current* value of that preset first as a baseline. Do not run `--full`
   without warning about the expected duration first.

7. Ask which benchmark mode: `fast` (default, ~5-7 min) or `full`/acceptance
   (~25-45 min). State the expected wall-clock for the chosen preset based on
   its n_ctx before running.

8. Ask whether to use `--exclusive` (measures cached model-load time and
   unloads other models first; use it the first time, or when comparing
   load behavior).

9. Ask one final question every time before any long run: "Is the machine
   idle right now?" The router serves `parallel = 1`, so concurrent agent
   traffic corrupts the measurements.

## Baseline

10. Run the baseline benchmark for the chosen preset with the chosen mode.
    Give the bash tool a generous `timeout` (`--full` on big presets can
    exceed 30 minutes). Save the JSON: `mkdir -p /tmp/llama-bench/<session>`
    and redirect stdout there. Use the exact same invocation shape for every
    later variant run so results are comparable (same mode, sizes, decode,
    gate, seed).

11. Summarize the baseline as a compact table: per size and mode — prompt &
    generation tok/s, TTFT, wall time, context capacity ok, gate status,
    VRAM peak/free. Read `raw_runs` for per-trial details (e.g.
    `cache_n`/`prompt_n` to confirm warm vs cold was real). State the verdict
    from the `gates` object.

## Propose one change

12. Diagnose using the baseline data and the preset's current values. Then
    propose **exactly one** `key = value` change worth testing, with the
    reasoning tied to what you measured. Examples of reasoning you may use:

    - Prefill slow but generation fine → try larger `batch-size` /
      `ubatch-size` (prefill is batched) or different `threads-batch`.
    - Generation slow → try `spec-draft-n-max` / `spec-type` (check
      `draft_n`/`draft_accepted` in `raw_runs` for acceptance rate) or
      `n-cpu-moe`.
    - Context capacity borderline or VRAM tight → consider `ctx-size`,
      `cache-type-k`/`cache-type-v`, `flash-attn`.
    - A knob is already optimal (e.g. changing it cannot help, or a
      parameter is at a sensible bound) → say so explicitly and explain why.

    Constraints on proposals:

    - Tunable keys only: `n-cpu-moe`, `threads`, `threads-batch`,
      `batch-size`, `ubatch-size`, `ctx-size`, `spec-draft-n-max`,
      `spec-type`, `cache-type-k`, `cache-type-v`, `flash-attn`, `fit`,
      `temperature`, `top-k`, `top-p`, `min-p`, `repeat-penalty`,
      `presence-penalty`, `frequency-penalty`.
    - Never propose changing: `hf`, `device`, `parallel`, `gpu-layers`,
      `alias`, `load-on-startup`.
    - Never lower `ctx-size` below the benchmark's gate context.
    - One key per iteration, never more.

13. Ask the user to approve the change before touching anything, and ask
    whether to keep the current benchmark mode for the verification run
    (recommended) or step up to `--full`.

## Apply, verify, decide

14. On approval:

    - Backup: `cp tag-ai/config/llama-cpp/preset.ini /tmp/llama-bench/<session>/preset.bak`
      and record the pre-edit state with
      `git diff -- tag-ai/config/llama-cpp/preset.ini`.
    - Apply the single change with the `edit` tool. Preserve the file's
      `key = value` formatting and section layout.
    - Reload the router: `curl -s 'http://127.0.0.1:10999/models?reload=1'`,
      then `POST /models/load` with `{"model":"<preset-id>"}` and poll
      `/models` until the model reports `loaded` (or run the benchmark with
      `--exclusive` so it handles the lifecycle itself).
    - Re-run the benchmark with the identical invocation from step 10.
    - Show a before/after table; compute deltas.

15. Decide with the user:

    - Better → offer to keep it, test another knob, or stop. If kept, the
      change is already live in the repo; mention that `rcup` will deploy it
      and that the router is already running it.
    - Worse or equal → restore the backup, reload the router, reload the
      model, and confirm the router is healthy. Then explain, using the
      measured numbers, why the current value was already good.

16. Loop back to step 12 (propose the next single knob) until the user says
    stop.

## Safety invariants

- Mutate the preset file only after explicit approval, and only via backup +
  edit + router reload (never overwrite the file wholesale).
- Never leave the router with a half-applied edit or an unloaded model.
  On any failure at any step, restore the backup, reload, and report.
- Keep benchmark invocations byte-identical across baseline and variants;
  only the preset value may differ.
- Leave no stray files in the repo; session artifacts stay in
  `/tmp/llama-bench/<session>/`.

## Finish

Provide a final summary: what was tested, measured deltas, the final state of
the preset (with `git diff` if changes were kept), and your recommendation
for the preset going forward.