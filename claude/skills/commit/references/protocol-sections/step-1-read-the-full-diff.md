## Step 1 — Read the Full Diff

Read the complete diff for all changes in the current branch:

```bash
git status
git diff
git diff --cached
git log --oneline -10
```

Read the diff carefully — every file, every hunk. Understand the full picture before planning commits:
- **What** changed (files, functions, modules, tests)
- **Why** it changed (infer from the diff context, commit history, branch name, and any arguments provided)
- **How** it changed (the approach — refactor, new code, config change, dependency update, etc.)
- **What else it affects** (callers, tests, related modules, deploy behavior)

If you are unsure about what a change does or why it was made, ask for clarification before proceeding.
