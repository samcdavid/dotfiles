---
model: sonnet
name: daily-wrapup
description: Consolidate today's Notion entry, summarize Linear/work activity, and rewrite actions, decisions, and notes into a clean end-of-day record.
disable-model-invocation: false
---

# Daily Wrapup

Produce a concise end-of-day record from today's work artifacts.

For Google Workspace and Slack, prefer the installed, already-authenticated `gws` and `slack` CLIs; use the corresponding MCP tools only as fallback. Never start interactive CLI authentication implicitly.

## Load Rules

Read `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For exact Notion formatting or edge cases, read `references/protocol.md`. Always read `references/activity-sources.md` before Phase 1 — it's what replaces manual per-task `log-work` calls with an automated pull of the day's real activity.

## Flow

1. Locate or create today's Notion entry.
2. Run the four activity sources (`references/activity-sources.md`): GitHub (`scripts/github-activity.sh`), Linear, Notion, and Slack — plus calendar context and today's raw Notion notes.
3. Deduplicate and rewrite actions, decisions, blockers, and accomplishments.
4. Preserve useful raw details only when they help tomorrow's handoff.
5. Update Notion.

## Output

Return what changed in Notion, a short accomplishment summary, open actions, blockers, and tomorrow carry-over.
