---
description: Start implementing a milestone from plan.md in a fresh session
agent: build
---

You are starting implementation from `plan.md` at the root of the current git
worktree (`git rev-parse --show-toplevel`; the working directory if not a git
repository). Read it in full first; it is self-contained and defines the task,
milestones, and an Execution Protocol you must follow.

Then:

1. Read the repository instructions (AGENTS.md, etc.).
2. List the milestones in `plan.md`. If `$ARGUMENTS` names one (e.g. "M2"),
   start there; otherwise ask which milestone to implement, defaulting to the
   first `Pending` required milestone.
3. Before editing, verify that milestone's prerequisites against the current
   repository, then set its status to `In Progress` in `plan.md`.
4. Work only on that milestone, following the Execution Protocol in `plan.md`:
   stop and record conflicts in Handoff Notes rather than changing scope, run
   every verification command, and mark `Completed` only after acceptance
   criteria pass.
5. Update `plan.md` as you go (statuses, Handoff Notes). Do not start another
   milestone unless asked.

If `plan.md` is missing, say so and suggest running `/make-plan` first.
