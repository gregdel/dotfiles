---
description: Explore a change interactively and return a self-contained plan
argument-hint: "<task>"
---

We are planning only. Do not modify files, staging state, or Git history.

Task:

$ARGUMENTS

Inspect the relevant implementation, tests, interfaces, configuration, Git
state, and repository constraints. Preserve unrelated user changes.

If a consequential decision cannot be resolved from the repository, ask me one
focused question at a time. In an interactive TUI, use `ask_question` with
concise, meaningful options (recommendation first); otherwise ask in plain
text. Briefly explain the trade-offs and your recommendation. Do not ask for
facts you can determine from the repository. Continue once important decisions
are resolved.

Respond with a self-contained implementation plan that does not rely on this
conversation. Include the task, verified context, resolved decisions, vertical
independently verifiable steps (with expected files/components and validation
for each), important constraints, and unresolved risks or assumptions. Do not
implement the plan or write it to a file.
