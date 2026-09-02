---
description: Implement the plan in .pi/plan.md
---

Implement the plan in `.pi/plan.md`.

First read the plan, the project's `AGENTS.md` files, the relevant existing
implementation and tests, and the current Git status and diff. Treat the plan
as a self-contained handoff, but verify its assumptions against the repository
before editing.

If `.pi/plan.md` is missing, unreadable, malformed, or still contains a
materially unresolved decision, explain the problem and stop without modifying
implementation files.

Execute the plan in vertical, independently verifiable steps. While working:

- preserve unrelated user changes;
- keep changes tightly scoped to the plan;
- maintain the repository's architecture and conventions;
- do not modify `.pi/plan.md` or `.pi/review.md`;
- do not stage, commit, or modify Git history;
- do not install missing tools or dependencies;
- run the cheapest relevant focused checks during implementation;
- run the appropriate focused tests or checks after the changes.

If a consequential decision becomes necessary and cannot be resolved from the
repository or plan, ask the user according to the active interaction guidance
before proceeding.

When finished, report concisely what changed, what was validated, anything that
could not be validated, and any material remaining risks.
