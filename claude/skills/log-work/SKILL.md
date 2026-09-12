---
model: sonnet
name: log-work
description: Append concise session accomplishments to today's Notion work log.
---

# Log Work

Record notable work from the current session in today's Notion entry.

## Load Rules

`~/.claude/rules/context-checkpoint.md` is already loaded as memory under Claude Code — apply it without re-reading; read the `~/.agents/rules/` equivalent explicitly under Codex. For Notion edge cases, read `references/protocol.md`.

## Flow

1. Infer what was accomplished from the conversation, git status, commands, and artifacts.
2. Find or create today's Notion entry.
3. Append concise action-oriented bullets.
4. Do not invent outcomes; distinguish completed work from investigation.

## Output

Return the bullets logged and the Notion entry name/link when available.

