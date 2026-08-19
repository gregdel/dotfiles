---
description: Write a self-contained implementation plan for fresh agents
agent: build
---

Create or update `plan.md` at the root of the current git worktree
(`git rev-parse --show-toplevel`), never in a subdirectory. If not in a git
repository, use the working directory. This file is the handoff artifact for
the complex task discussed in this session. Treat `$ARGUMENTS` as additional
task details or constraints.

Do not implement the task. Repository inspection and edits to `plan.md` are the
only changes allowed.

## Process

1. Derive the goal, constraints, decisions, and unresolved questions from the
   conversation and `$ARGUMENTS`. If the objective is unclear, ask for it.
2. Read repository instructions and inspect enough of the codebase to verify
   relevant architecture, files, symbols, conventions, and test commands. Do
   not guess details that can be checked.
3. Before writing, identify ambiguities that would materially affect scope,
   architecture, interfaces, or milestone boundaries. Ask concise clarification
   questions in one batch and wait for answers. Record non-blocking assumptions
   explicitly.
4. If `plan.md` exists, determine whether it covers the same task. Preserve
   relevant progress and decisions for the same task. Ask before replacing a
   plan for a different task.
5. Decompose the task into independently selectable vertical milestones.
6. Write the complete plan to `plan.md`.
7. Before finishing, verify the plan is internally consistent: every
   Dependencies and Parallel With entry names an existing milestone ID, the
   Milestone Overview table rows match the milestone sections, and statuses
   agree.

## Plan Requirements

- Make the document self-contained: never refer to "this conversation",
  "above", or other context unavailable to a fresh agent. Every milestone must
  be independently actionable with only the repository and `plan.md`; include
  all milestone-specific context needed to execute it without prior session
  history.
- State the intended outcome, verified repository baseline, constraints,
  non-goals, assumptions, and important design decisions.
- Make each milestone an independently useful vertical slice that leaves the
  repository coherent and testable.
- Mark every milestone as required or optional. An optional milestone must
  never be a prerequisite for another milestone, and skipping it must not
  invalidate the acceptance criteria of selected milestones.
- Minimize dependencies between required milestones. If work cannot produce a
  useful result independently, merge it with the milestone that needs it. When
  a dependency is technically unavoidable, name the exact prerequisite and
  artifact it produces.
- State which milestones can run in parallel. Do not imply an execution order
  where none is required.
- Identify concrete files and symbols when verified. Clearly label files that
  must be created and avoid inventing unverified paths or APIs.
- Include acceptance criteria and exact verification commands for every
  milestone.
- Capture risks, edge cases, migration or compatibility concerns, and deferred
  work where relevant.
- Prefer implementation guidance over large code listings. Include snippets
  only when an interface or invariant must be exact.
- Keep each milestone small enough for one agent session.

## Execution Protocol

Include these instructions in `plan.md` for implementing agents:

- Work only on the assigned milestone; do not start another milestone.
- Confirm the milestone's prerequisites against the current repository before
  editing, then mark its status `In Progress`.
- If repository reality conflicts with the plan, stop and record the conflict
  in Handoff Notes. Ask for direction rather than silently changing scope.
- Run every verification command and record relevant results.
- Mark the milestone `Completed` only after its acceptance criteria pass.
- Keep the milestone's status consistent in both the Milestone Overview table
  and the milestone's header when changing it.
- Mark an omitted milestone `Skipped` with a reason. Skipping an optional
  milestone must not block any selected milestone.
- Record decisions, deviations, and useful context in Handoff Notes so another
  fresh agent can continue.

## Required Structure

```markdown
# <Task Title>

## Goal
## Repository Baseline
## Constraints and Non-Goals
## Decisions and Assumptions
## Execution Protocol
## Milestone Overview

| ID | Milestone | Required | Dependencies | Parallel With | Status |
|----|-----------|----------|--------------|---------------|--------|

## Milestone M1: <Outcome>
**Status:** Pending
**Required:** Yes or No
**Dependencies:** None
**Parallel With:** None

### Context
### Outcome
### Scope
### Out of Scope
### Files and Symbols
### Implementation
- [ ] Step that must be done
### Acceptance Criteria
- [ ] Criterion that must hold
### Verification
### Handoff Notes

## Milestone M2: <Outcome>
...

## Integration and Final Verification
### Selected Scope
### Integration Checks
### Acceptance Criteria
### Verification

## Risks and Open Questions
```

Use checkboxes for implementation and acceptance items. Integration checks must
validate any supported selection of optional milestones rather than assuming
that every milestone was implemented.

After writing the file, summarize its path, milestone count, assumptions, and
any questions that remain unresolved.
