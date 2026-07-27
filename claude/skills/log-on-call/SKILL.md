---
model: sonnet
name: log-on-call
description: Log an off-hours on-call incident to the daily Notion doc with a timeline useful for follow-up or postmortem.
disable-model-invocation: true
---

# Log On Call

Record an on-call incident in the daily Notion entry.

## Load Rules

Read `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For Notion formatting details, read `references/protocol.md`.

## Flow

1. Determine incident date, time range, trigger, affected system, impact, actions taken, and outcome.
2. Ask only for missing incident facts that cannot be inferred.
3. Find or create the day's Notion entry and mark it as on-call/off-hours when supported.
4. Add a timeline, resolution summary, and follow-ups.

## Output

Return what was logged, unresolved questions, and follow-up actions.

