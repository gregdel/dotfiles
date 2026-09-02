---
description: Explore a change interactively and write a self-contained plan
argument-hint: "<task>"
---

We are planning only. Do not modify implementation, test, configuration, or
documentation files. The only permitted repository change is creating or
overwriting `.pi/plan.md` after planning is complete.

Task:

$ARGUMENTS

First inspect the repository sufficiently to understand the relevant existing
implementation, tests, interfaces, configuration, current Git state, and
constraints. Preserve unrelated user changes.

Then identify unresolved decisions that would materially affect the
implementation.

For each unresolved decision:

1. In an interactive TUI session, use `ask_question` to ask me exactly one
   focused question at a time. Give one to three concise, meaningful options,
   ordered with your recommendation first. In non-interactive sessions, ask in
   plain assistant text.
2. Explain the relevant trade-offs concisely.
3. Give your recommended answer and why.
4. Do not ask me for information you can determine reliably from the repository.

Continue until the important decisions are resolved.

Create `.pi/` if necessary, then overwrite `.pi/plan.md` with a self-contained
implementation plan. It must not rely on this conversation. Include:

- the task;
- verified repository context relevant to implementation;
- resolved decisions;
- vertical, independently verifiable implementation steps;
- files/components expected to change;
- important invariants and constraints;
- validation for each step;
- unresolved risks or assumptions.

Do not implement the plan and do not modify any other file. Finish with a
concise confirmation that `.pi/plan.md` was written.
