---
description: Review staged Git changes without modifying the repository
agent: plan
subtask: true
---

Review only the changes currently staged in the Git index. Treat `$ARGUMENTS`
as an optional review focus. Do not edit files, run tests, stage changes, or
perform any operation that changes repository state.

## Process

1. Read the repository instructions.
2. Run `git status --short`, `git diff --cached --stat`, and
   `git diff --cached --check`.
3. If the index contains no changes, state that and stop.
4. Inspect the complete staged diff with rename detection. Read surrounding
   source when needed to understand behavior and established conventions.
5. Review the indexed snapshot, not unrelated unstaged content. If a path also
   has unstaged changes, use `git show :<path>` to inspect the staged version.
6. Check for correctness defects, behavioral regressions, security issues,
   unsafe error handling, concurrency or resource-lifetime problems,
   compatibility concerns, and missing tests. Avoid style-only findings unless
   they materially affect correctness or maintainability.

## Output

- Present findings first, ordered by severity.
- Label findings `P0` through `P3` and include staged file and line references.
- Explain the concrete failure mode and a concise corrective direction.
- Follow with open questions or assumptions, then a brief testing-gap summary.
- If there are no findings, say so explicitly and mention any residual risks or
  verification gaps.
