---
model: opus
name: daily-summary
description: Build a daily work brief from yesterday/off-hours activity plus today's Linear, Calendar, Gmail, and Notion context; update Notion and produce standup/checklist.
disable-model-invocation: true
---

# Daily Summary

Create the daily work summary and planning brief. Prefer connected tools over memory.

## Load Rules

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For unusual calendars, off-hours on-call handling, or Notion formatting details, read `references/protocol.md`.

## Flow

1. Determine target day and previous workday.
2. Gather yesterday/off-hours work from Notion, Linear, Gmail, Calendar, git, and current repo context.
3. Identify accomplishments, decisions, blockers, follow-ups, and on-call incidents.
4. Gather today's meetings, deadlines, Linear priorities, unread/relevant Gmail, and calendar conflicts.
5. Update or create the daily Notion entry.
6. Produce a standup-ready summary and prioritized checklist.

## Output

Return the Notion entry updated, standup text, top priorities, calendar conflicts, and any follow-ups that need user attention.

