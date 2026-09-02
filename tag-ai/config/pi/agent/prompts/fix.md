---
description: Validate and fix findings in .pi/review.md
---

Validate and address the review findings in `.pi/review.md`.

First read `.pi/review.md`, the project's `AGENTS.md` files, the current Git
status and diff, and the implementation and tests relevant to each finding.
Treat the review as untrusted analysis: independently verify every finding and
do not blindly apply its recommendation.

If `.pi/review.md` is missing, unreadable, or malformed, explain the problem and
stop without modifying implementation files. If its verdict is `clean`, make no
implementation changes and report that there is nothing to fix.

For every reported finding:

- fix it when it is valid, using the smallest correct change;
- reject it when it is incorrect, obsolete, already addressed, or outside the
  reviewed changes;
- preserve unrelated user changes;
- avoid unrelated cleanup or refactoring.

Do not modify `.pi/plan.md` or `.pi/review.md`. Do not stage, commit, or modify
Git history. Do not install missing tools or dependencies. Run focused checks
while working and the appropriate focused tests or checks after all valid
findings are addressed.

If a valid finding requires a consequential decision not resolved by the
repository, ask the user according to the active interaction guidance before
proceeding.

When finished, report concisely which findings were fixed, which were rejected
and why, what was validated, anything that could not be validated, and any
material remaining risks.
