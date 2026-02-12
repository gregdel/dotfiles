---
description: Update AGENTS.md with learnings from this session
---

Review this session for learnings about working with AI agents in this
codebase. Update AGENTS.md with context that would help future sessions be more
effective. If AGENTS.md is not present, use CLAUDE.md.

## Step 1: Reflect

What context was missing that would have helped the agent work more effectively?
- Bash commands that were used or discovered
- Code style patterns followed
- Testing approaches that worked
- Environment/configuration quirks
- Warnings or gotchas encountered

## Step 2: Find AGENTS.md Files

```bash
fd "(CLAUDE|AGENTS).md$" --type file
```

## Step 3: Draft Additions

**Keep it concise** - one line per concept. AGENTS.md is part of the prompt, so brevity matters.

Format: `<command or pattern>` - `<brief description>`

Avoid:
- Verbose explanations
- Obvious information
- One-off fixes unlikely to recur

## Step 4: Show Proposed Changes

For each addition:

```
### Update: ./AGENTS.md

**Why:** [one-line reason]

\`\`\`diff
+ [the addition - keep it brief]
\`\`\`
```

## Step 5: Apply with Approval

Ask if the user wants to apply the changes. Only edit files they approve.
