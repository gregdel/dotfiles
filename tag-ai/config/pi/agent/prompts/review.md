---
description: Review all current Git changes and write .pi/review.md
---

Review all task-relevant changes in the current Git working tree and write the
result to `.pi/review.md`.

The only permitted repository change is creating or overwriting
`.pi/review.md`. Do not modify implementation, test, configuration,
documentation, `.pi/plan.md`, staging state, or Git history.

First read the project's `AGENTS.md` files and verify that the working directory
is a Git repository with a valid `HEAD`. Then inspect:

- `git status --short`;
- all staged and unstaged tracked changes versus `HEAD`;
- every relevant untracked file;
- the surrounding implementation, interfaces, and tests needed to validate the
  changed behavior.

Exclude `.pi/plan.md` and `.pi/review.md` from the review scope. Do not exclude a
file merely because it is untracked. Avoid reviewing unrelated generated,
vendored, ignored, or third-party content.

Record only concrete, actionable defects introduced or exposed by the current
changes, including correctness bugs, regressions, security problems, material
error-handling gaps, and missing validation that materially affects behavior.
Verify each finding against the repository. Omit style preferences, praise,
speculation, and optional refactors.

Create `.pi/` if necessary, then overwrite `.pi/review.md` using this format:

```markdown
# Review

## Scope
- Base: HEAD
- Files: path/to/file, ...

## Verdict
clean | findings

## Findings

### P0 | P1 | P2 — Short title
- Location: path/to/file:line
- Problem: What is wrong and under what conditions.
- Impact: Why it materially matters.
- Recommended fix: The smallest correct remediation.
```

Use P0 for critical/blocking defects, P1 for serious defects, and P2 for other
material defects. Order findings by priority. If there are no actionable
findings, write `clean` as the verdict and `No actionable findings.` under
`## Findings`.

Finish with a concise confirmation that `.pi/review.md` was written and state
the verdict. Do not duplicate the full review in the response.
