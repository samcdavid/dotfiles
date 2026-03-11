---
name: daily-summary
description: Daily workflow that summarizes yesterday's work in Notion, generates a standup for clipboard, and builds today's prioritized checklist from Linear and Google Calendar.
disable-model-invocation: true
---

# Daily Summary

You are helping me with my daily planning workflow. Follow these phases in order.

## Phase 1 — Gather Context

Fetch all of the following in parallel:

1. **Notion**: Search Notion for my yearly ToDo doc (titled with the current year, e.g., "2026 ToDo"). Fetch yesterday's entry from it. "Yesterday" means the most recent workday (skip weekends/holidays). Read all activities, actions, decisions, and general notes for that day.
2. **Linear**: List issues assigned to me. Also list the Linear projects I am a member of.
3. **Google Calendar**: Use Google Calendar to review my calendar for today — meetings, events, and time blocks.

## Phase 2 — Enrich

For every Linear issue referenced in yesterday's Notion entry:
- Get the full issue details from Linear (status, description, comments, PR links).

This context is needed for writing the summary and standup.

## Phase 3 — Write Yesterday's Summary

In the Notion doc, write a summary under the **##Summary** section for yesterday's date. Write it in a way that would be useful for a future performance review:
- Emphasize impact, decisions made, and problems solved.
- Note meaningful collaboration or unblocking others.
- Keep it concise but substantive — a few sentences, not a task list.

## Phase 4 — Generate Standup

Write an async standup update using the format below. Use concise bullet points per item — each bullet should include the **Linear issue ID**, its **current status**, and a **PR link** if one exists. Do not include issue titles, only the ID (e.g., ABC-123). Use natural, human language — brief but not robotic.

```
Y:
- ABC-123: moved to code review (PR: <link>)
- ABC-789: still in progress, debugging test failures

T:
- ABC-123: verify in staging
- ABC-789: continue work, target ready for review
```

**Parking Lot** — only include a `PL:` section if there is something that genuinely needs to be discussed with the entire team. If nothing qualifies, omit the section entirely.

Copy the standup to my clipboard using `pbcopy`.

## Phase 5 — Build Today's Checklist

Using the gathered context from Linear (assigned issues, project priorities) and Google Calendar (today's meetings), add a checklist to **Today's** entry in the Notion doc. Order items from highest to lowest priority. Include meetings at the appropriate priority level based on their importance and timing.
