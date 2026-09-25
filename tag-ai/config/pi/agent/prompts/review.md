---
description: Review staged changes or a requested Git change
argument-hint: "[what to review]"
---

Review only. Do not modify files, the Git index, or history.

Requested scope: $ARGUMENTS

If a scope is requested, review it instead of staged changes. Interpret plain
language using the repository: "the last commit" means `git show HEAD`, and
"the diff from master" means `git diff master...HEAD` (changes on the current
branch since the common ancestor). Ask if the target or direction is unclear.

Without a request, review `git diff --cached`. If it is empty, ask me what to
review instead: the last commit, the diff from master, or another commit or
branch comparison. In an interactive TUI, use `ask_question`; otherwise ask in
plain text. Wait for my answer rather than guessing.

Review only the selected changes. Inspect relevant surrounding code and tests
as needed, but do not include unrelated unstaged or untracked changes. When
reviewing staged changes, use the index version rather than newer working-tree
edits to assess findings.

Report only concrete, actionable defects introduced by the selected changes,
ordered by severity. Give each finding a file and line, its impact, and a
concise fix. State the scope reviewed; if there are no actionable findings,
say so. Do not write a review file.
