---
model: sonnet
name: daily-wrapup
description: Consolidate today's Notion entry, summarize Linear/work activity, and rewrite actions, decisions, and notes into a clean end-of-day record.
---

# Daily Wrapup

Produce a concise end-of-day record from today's work artifacts.

## Load Rules

Read `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For exact Notion formatting or edge cases, read `references/protocol-index.md`.

## Flow

1. Locate or create today's Notion entry.
2. Collect today's Linear changes, Git activity, calendar context, and session notes.
3. Deduplicate and rewrite actions, decisions, blockers, and accomplishments.
4. Preserve useful raw details only when they help tomorrow's handoff.
5. Update Notion.

## Output

Return what changed in Notion, a short accomplishment summary, open actions, blockers, and tomorrow carry-over.

