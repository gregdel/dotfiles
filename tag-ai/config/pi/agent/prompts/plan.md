---
description: Explore and plan a change interactively
argument-hint: "<task>"
---

We are planning only. Do not modify the repository.

Task:

$ARGUMENTS

First inspect the repository sufficiently to understand the relevant existing
implementation, tests, interfaces, configuration, and constraints.

Then identify unresolved decisions that would materially affect the
implementation.

For each unresolved decision:

1. Ask me one focused question at a time.
2. Explain the relevant trade-offs concisely.
3. Give your recommended answer and why.
4. Do not ask me for information you can determine reliably from the repository.

Continue until the important decisions are resolved.

Then produce an implementation plan consisting of vertical, independently
verifiable steps. Include:

- files/components expected to change;
- important invariants and constraints;
- validation for each step;
- unresolved risks or assumptions.

Do not implement the plan.
