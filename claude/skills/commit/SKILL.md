---
model: sonnet
name: commit
description: Stage and commit changes in logical groups using the project's git message style, without mixing unrelated user changes.
---

# Commit

Create one or more focused commits from the current working tree.

## Load Rules

Read `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex. For project-specific message templates or edge cases, read `references/protocol-index.md`.

## Flow

1. Inspect `git status`, diffs, and recent commits.
2. Separate unrelated/user changes from your changes.
3. Group files into logical commits; each file belongs to exactly one commit.
4. Stage only the intended files.
5. Write a detailed commit message matching the local template/style.
6. Commit locally. Do not push unless explicitly asked.

## Output

Return commit SHA(s), subject(s), files included, and any uncommitted changes left behind.

