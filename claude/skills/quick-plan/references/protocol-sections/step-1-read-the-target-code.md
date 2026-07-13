## Step 1 — Read the Target Code

Read every file the change will touch. Stay scoped — don't explore broadly. Check git state to understand what's already in flight:

```bash
git status
git diff HEAD
```

If a research artifact path was passed, read it. Also check `~/.claude/thoughts/shared/research/` for any recent artifact matching this topic.

Spawn a **codebase-pattern-finder** for any function being added or restructured — confirm the codebase doesn't already have a utility doing the same thing. Duplicating existing functionality on a change round is a common rework trigger.
