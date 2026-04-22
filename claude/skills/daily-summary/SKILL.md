---
name: daily-summary
description: Daily workflow that summarizes yesterday's work in Notion, generates a standup for clipboard, and builds today's prioritized checklist from Linear, Google Calendar, and Gmail.
disable-model-invocation: true
---

# Daily Summary

You are helping me with my daily planning workflow. Follow these phases in order.

## Phase 0 — Resolve Arguments

`$ARGUMENTS` should contain two things:
1. A **Notion database URL** for the Daily ToDo database (e.g., `https://www.notion.so/...`)
2. A **Slack channel or thread URL** where the standup should be posted (e.g., `https://app.slack.com/client/...`)

If either is missing, ask the user before proceeding. Once you have both:
- **Fetch the Notion database** using the URL to discover its data source ID (look for the `<data-source url="collection://...">` tag in the fetch result). Use this data source ID for all subsequent Notion queries and page creation.
- **Parse the Slack URL** to extract the channel ID (and thread timestamp, if present) for posting the standup in Phase 4.

## Phase 1 — Gather Context

Fetch all of the following in parallel:

1. **Notion**: Query the Daily ToDo database (using the data source ID resolved in Phase 0) for yesterday's entry. "Yesterday" means the most recent workday (skip weekends/holidays). Query with: `SELECT * FROM "<data_source_id>" WHERE "date:Date:start" = '<YYYY-MM-DD>'`. If no result, try the previous workday. Fetch the page to read all activities, actions, decisions, and general notes for that day.
2. **Linear**: List issues assigned to me. Also list the Linear projects I am a member of.
3. **Google Calendar**: Use Google Calendar to review my calendar for today — meetings, events, and time blocks. Also fetch the next 7 calendar days and look for **PTO / time-off**: any all-day events whose title contains words like "PTO", "OOO", "Vacation", "Off", "Out of Office", "Holiday", or similar. Include company-wide holidays (they will appear as all-day events on my calendar). If I have consecutive days off, extend the lookup until you find the first day I'm back in office.
4. **Gmail**: Search Gmail for messages in my inbox. Focus on unread and recent messages that are work-related and require action — replies needed, requests, approvals, follow-ups, or deadlines. Ignore marketing emails, newsletters, promotional content, and automated notifications that don't require a response.

## Phase 2 — Enrich

For every Linear issue referenced in yesterday's Notion entry:
- Get the full issue details from Linear (status, description, comments, PR links).

This context is needed for writing the summary and standup.

## Phase 3 — Write Yesterday's Summary

In yesterday's database page, write a summary under the **## Summary** section using `notion-update-page` with `update_content`. Write it in a way that would be useful for a future performance review:
- Emphasize impact, decisions made, and problems solved.
- Note meaningful collaboration or unblocking others.
- Keep it concise but substantive — a few sentences, not a task list.
- After writing the summary, update the page's Status property to "Complete".

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

**Out of Office** — if any PTO days, vacation, or company holidays were found in the next 7 days (or beyond, if consecutive days off extend further), add an `OOO:` section after the `T:` section. List the dates and reason (e.g., "PTO", "Company Holiday — Good Friday"). If I'm out for a block of consecutive days, show the range and note when I'll be back (e.g., "OOO Mon 3/30 – Wed 4/1, back Thu 4/2"). If no upcoming time off was found, omit the section entirely.

**Parking Lot** — only include a `PL:` section if there is something that genuinely needs to be discussed with the entire team. If nothing qualifies, omit the section entirely.

Copy the standup to my clipboard using `pbcopy`.

Then post the standup to the Slack channel/thread resolved in Phase 0 using the Slack MCP `send_message` tool. If a thread URL was provided, reply in that thread. If just a channel URL, post as a new message.

## Phase 5 — Build Today's Checklist

Using the gathered context from Linear (assigned issues, project priorities), Google Calendar (today's meetings), and Gmail (actionable emails), create **Today's** entry in the Daily ToDo database.

1. **Create today's page** using `notion-create-pages` with the data source ID resolved in Phase 0:
   - Properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "Workday" (or "PTO"/"Holiday" if applicable)
   - Content: Start with `## Checklist` section containing prioritized items, then empty `## Actions and decisions`, `## Notes`, and `## Summary` sections.

2. **Order checklist items** from highest to lowest priority. Include meetings at the appropriate priority level based on their importance and timing. For email-sourced items, include enough context to act on them (sender, subject, what's needed) without needing to re-read the email.
