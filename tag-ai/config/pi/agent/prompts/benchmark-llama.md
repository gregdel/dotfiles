---
description: Benchmark and tune the active Pi llama.cpp model
---

Benchmark the llama.cpp model currently selected in Pi, summarize its usable
context and generation speed, then optionally make one local preset-key change.
The benchmark itself is read-only. Deployment and verification are always
manual and happen after this invocation.

## Preconditions

Before running anything:

1. Verify `git rev-parse --show-toplevel` is `$HOME/.dotfiles` and the checkout
   is writable. Otherwise tell the user to run:

   `cd ~/.dotfiles && ppi`

   Then stop.

2. Read these files:

   - `tag-ai/config/llama-cpp/preset.ini`
   - `tag-ai/local/bin/llama-cpp-benchmark`

3. Check `PI_PROVIDER` and `PI_MODEL` through the shell environment.
   `PI_PROVIDER` must be `llama.cpp`. If not, tell the user to load the desired
   preset with `/llama`, select it with `/model`, and invoke this prompt again.

4. Confirm the selected model has a matching local preset section. Do not infer
   a different preset from an HF repository name.

5. Inspect `git status` and the existing diff for `preset.ini`. Never overwrite
   or fold unrelated user changes into a benchmark adjustment.

6. Ask whether the machine is in its normal representative state and ready for
   a long benchmark. Concurrent inference or unusual GPU load makes comparisons
   invalid. Do not run until confirmed.

## Run once

Run `llama-cpp-benchmark` exactly once with no arguments and a timeout of at
least 30 minutes. Save its stdout under `/tmp` using `PI_SESSION_ID` in the
filename, while retaining its exit status. Do not invoke any router lifecycle
endpoint and do not alter files during the run.

The fixed workload measures:

- 8,192 total tokens (diagnostic baseline)
- 65,536 total tokens (required minimum)
- 100,000 total tokens (preferred)
- 512 generated tokens, twice per depth
- best-effort local VRAM peak with a 200 MiB free-memory requirement

Validate the output as JSON schema version 1. If the script reports a preflight
error, explain it and stop. A benchmark verdict of `failed` is still a valid
result and must be summarized.

## Present the result

Show a compact table with one row per context depth:

- actual input tokens
- cold prefill seconds and tokens/s
- each generation tokens/s sample and their median
- minimum free VRAM, when available
- status and failure reason

Then show:

- effective server context and relevant preset arguments
- global peak/free VRAM and whether it was measurable
- final verdict: `failed`, `minimum`, or `preferred`

State explicitly that this measures operational capacity and throughput, not
whether the model uses long context intelligently.

## Compare and diagnose

When a previous schema-v1 result for the same model and workload version exists
in the conversation, compare only if the benchmark contract is identical and
the preset differs by the intended key. Compute proportional deltas at 65,536
and 100,000 tokens. Treat changes within ±5% as inconclusive.

Rank configurations in this order:

1. Reject one that cannot complete 65,536 tokens.
2. When VRAM is measurable, reject one leaving less than 200 MiB free there.
3. Prefer one that also completes 100,000 tokens with sufficient headroom.
4. Between equal-capacity configurations, require at least 5% combined
   generation-speed improvement at 65,536 and 100,000 tokens, without a
   material regression at either depth.
5. Use 8,192-token speed only as a diagnostic.

The only tunable keys in this workflow are:

- `n-cpu-moe`
- `threads`
- `spec-type`
- `spec-draft-n-max`
- `spec-draft-p-min`
- `ctx-size` (never below 65,536)
- `cache-type-k`
- `cache-type-v`

Do not change the model artifact, sampling, template settings, device,
GPU-layer policy, batch sizes, parallelism, or load policy.

For the initial Tiel MTP preset, if capacity and VRAM pass and there is no prior
comparison, testing `spec-type = none` is the first useful control. If capacity
or VRAM fails, address placement or context before speculative decoding.

## Optional local edit

After presenting all results, propose at most one exact `key = value` change,
tied directly to the measurements. If no change is justified, say so and stop.

Ask for approval. Only after approval:

1. Edit that one key in the active model's local preset section.
2. Preserve INI formatting and all unrelated changes.
3. Show `git diff -- tag-ai/config/llama-cpp/preset.ini`.
4. Stop. Tell the user to deploy the dotfiles change manually, reload/load the
   preset themselves, and invoke `/benchmark-llama` again for verification.

Never reload, load, unload, or download a model. Never make a second preset
change in the same invocation.
