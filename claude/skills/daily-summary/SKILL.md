---
model: sonnet
name: daily-summary
description: Daily workflow that summarizes the previous workday (plus any off-hours On Call days) in Notion, generates a standup for clipboard, and builds today's prioritized checklist from Linear, Google Calendar, and Gmail.
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

1. **Notion**: Fetch the Daily ToDo database in **view mode** (sorted descending by Date, `page_size: 10` — per the `Notion SQL date-filter` gotcha; do not use SQL mode). From the returned entries, identify **every day that needs reviewing**:
   - **The previous workday** — the most recent entry before today whose `Day Type` is a normal working day (`Workday`). This is **always** reviewed, even if on-call days sit between it and today.
   - **On-call days since then** — every entry dated *after* that previous workday and *before* today whose `Day Type` is `On Call`. These are off-hours incident days (e.g., a weekend page) logged by the `log-on-call` skill, and must be reviewed too. There may be zero, one, or several.
   Fetch each identified page (the previous workday **plus** any on-call days) in full to read all activities, actions, decisions, and notes. If `page_size: 10` does not reach back far enough to include the previous workday (e.g., a long holiday/PTO gap), increase it until it does.
2. **Linear**: List issues assigned to me. List the Linear projects I am a member of, and for each project with an active milestone, also list its **open issues regardless of assignee** (`state.type` in `unstarted` or `started`) — not just mine. This gives the project-wide priority view (what the team is gating on, what's grabbable) rather than only my queue. Scope each query per the `list_issues` gotcha to keep results bounded.
3. **Google Calendar**: Use Google Calendar to review my calendar for today — meetings, events, and time blocks. Also fetch the next 7 calendar days and look for **PTO / time-off**: any all-day events whose title contains words like "PTO", "OOO", "Vacation", "Off", "Out of Office", "Holiday", or similar. Include company-wide holidays (they will appear as all-day events on my calendar). If I have consecutive days off, extend the lookup until you find the first day I'm back in office.
4. **Gmail**: Search Gmail for messages in my inbox. Focus on unread and recent messages that are work-related and require action — replies needed, requests, approvals, follow-ups, or deadlines. Ignore marketing emails, newsletters, promotional content, and automated notifications that don't require a response.

## Phase 2 — Enrich

For every Linear issue referenced in the reviewed Notion entries (the previous workday **and** any on-call days):
- Get the full issue details from Linear (status, description, comments, PR links).

This context is needed for writing the summaries and standup.

## Phase 3 — Write Summaries

Write a **## Summary** for **each** reviewed page — the previous workday and every on-call day — using `notion-update-page` with `update_content`. After writing each summary, set that page's Status property to "Complete".

**Previous workday.** Write it in a way that would be useful for a future performance review:
- Emphasize impact, decisions made, and problems solved.
- Note meaningful collaboration or unblocking others.
- Keep it concise but substantive — a few sentences, not a task list.

**On-call days.** Write an incident-flavored summary that will be useful for a post-mortem and a performance review:
- Lead with what triggered the page and the impact (what was broken, who/what was affected).
- State the resolution and how it was reached — root cause if known, mitigation applied.
- Note follow-ups created (tickets to file, fixes deferred to business hours).
- Keep it concise; the page's Actions and decisions already hold the timeline detail.

## Phase 4 — Generate Standup

Write an async standup update using the format below. Use concise bullet points per item — each bullet should include the **Linear issue ID**, its **current status**, and a **PR link** if one exists. Do not include issue titles, only the ID (e.g., ABC-123). Use natural, human language — brief but not robotic.

```
Y:
- ABC-123: moved to code review (PR: <link>)
- ABC-789: still in progress, debugging test failures

On-call:
- Sat 5/30: paged for API 5xx spike on X, mitigated by Y (incident <link or ticket>)

T:
- ABC-123: verify in staging
- ABC-789: continue work, target ready for review
```

**On-call** — if any on-call days were reviewed in Phase 1, add an `On-call:` section between `Y:` and `T:`. One bullet per incident day: the date, what triggered the page, and how it was resolved, with an incident/ticket reference if one exists. If no on-call days were reviewed, omit the section entirely. Do not invent on-call items — only days that have an actual `On Call` page from Phase 1 qualify.

**Out of Office** — if any PTO days, vacation, or company holidays were found in the next 7 days (or beyond, if consecutive days off extend further), add an `OOO:` section after the `T:` section. List the dates and reason (e.g., "PTO", "Company Holiday — Good Friday"). If I'm out for a block of consecutive days, show the range and note when I'll be back (e.g., "OOO Mon 3/30 – Wed 4/1, back Thu 4/2"). If no upcoming time off was found, omit the section entirely.

**Parking Lot** — only include a `PL:` section if there is something that genuinely needs to be discussed with the entire team. If nothing qualifies, omit the section entirely.

**Adversarial verification — before publishing.** Dispatch the `adversarial-debate` agent (via the `Agent` tool, `subagent_type: "adversarial-debate"`) with the drafted Y:/T:/OOO:/PL: text and the list of Linear ticket IDs cited. The agent must independently re-fetch each cited ticket with `get_issue` and challenge:
- Every status word ("merged", "in review", "shipped", "blocked") against current Linear state.
- Every PR link — does it resolve, and is it actually linked to the cited ticket?
- Every T: item — is the ticket still open (`state.type` not `completed` or `canceled`)?
- Any OOO claim — does it match a real calendar event found in Phase 1?
- Every On-call: bullet — does it trace to a real `On Call` page reviewed in Phase 1, and does its date and resolution match that page's content (no invented incidents, no misattributed dates)?

Apply every correction the agent surfaces before continuing. Do not publish a draft the agent has open contradictions on.

Then copy the standup to my clipboard using `pbcopy` and post it to the Slack channel/thread resolved in Phase 0 using the Slack MCP `send_message` tool. If a thread URL was provided, reply in that thread. If just a channel URL, post as a new message.

## Phase 5 — Build Today's Checklist

Using the gathered context from Linear (assigned issues **and project-wide open issues**, project priorities), Google Calendar (today's meetings), and Gmail (actionable emails), create **Today's** entry in the Daily ToDo database.

**Operative principle — parallel-work, PR-by-EOD.** The checklist is a list of issues I can work in parallel today and realistically have an open PR on by end of day, accounting for today's meeting load. Use this as the inclusion filter:
- Issues larger than one day do **not** belong on the checklist. Flag them in the milestone-review block (step 4) under **Needs breakdown** so I can split them into smaller issues — and if the right next move is one of them, identify a single-PR-sized **first slice** and put that slice on the checklist.
- Project-wide importance (from the broader Phase 1 Linear pull, not just my assigned list) feeds prioritization: a high-importance unassigned ticket I can grab and PR today is a valid checklist row, even if no one has assigned it yet.

1. **Filter completed work before write.** For every Linear ticket that is a candidate for today's checklist (yesterday's leftovers, assigned issues, email/calendar mentions), call `get_issue` and **drop any whose `state.type` is `completed` or `canceled`**. A ticket that closed yesterday — even one that appeared in Phase 4's Y: block — must not be written as today's T: item or checklist row. This is a hard gate, not a heuristic.

2. **Create today's page** using `notion-create-pages` with the data source ID resolved in Phase 0:
   - Properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "Workday" (or "PTO"/"Holiday" if applicable)
   - Content: Start with `## Checklist` section containing prioritized items, then empty `## Actions and decisions`, `## Notes`, and `## Summary` sections.

3. **Order checklist items** from highest to lowest priority. Include meetings at the appropriate priority level based on their importance and timing. For email-sourced items, include enough context to act on them (sender, subject, what's needed) without needing to re-read the email.

4. **Project milestone review.** Identify the user's primary active project(s) — heuristic: the project of the most-recently-updated assigned issue, plus any projects where the user is lead. For each, fetch the **active milestone** and list its tickets in `unstarted` and `started` states. Then update today's page to populate the `## Notes` section with a forward-looking block covering:
   - **Urgent — mine**: Urgent-priority tickets assigned to the user.
   - **Urgent — grabbable**: Urgent-priority tickets that are unassigned and ready (no blockers).
   - **High — unassigned bottlenecks**: High-priority unassigned tickets that gate milestone progress.
   - **Needs breakdown**: open tickets in the active milestone that look larger than one day of work — flag them so I can split them into smaller, PR-sized issues. Include a one-line note per ticket on what makes it oversized (multiple surfaces, unknowns, multiple PRs implied).
   - **Recommended next-work order**: a short ordered list naming the next 2–3 tickets to pick up and a one-line reason each (e.g., "MCP-44 — Urgent/unassigned/ready, natural first sub-task of MCP-40").

   This block is standard output, not optional. If a milestone has nothing in those buckets, write that explicitly rather than omitting the section.

## Phase 6 — Adversarial Verification of Today's Page

After Phase 5 has drafted the checklist and milestone-review block (but **before** they are written to Notion via `notion-create-pages` / `notion-update-page`), dispatch the `adversarial-debate` agent (via the `Agent` tool, `subagent_type: "adversarial-debate"`) with the full drafted page content and the list of every Linear ticket ID, project, milestone, sender, and meeting it cites. The agent must independently re-verify, not trust the draft:

- **Closed-work leakage**: re-fetch each checklist ticket with `get_issue`; flag any with `state.type` in `{completed, canceled}` (defense-in-depth on top of Phase 5 step 1).
- **Priority/assignee claims**: every "Urgent — mine" / "Urgent — grabbable" / "High — unassigned bottleneck" ticket must currently match that priority and assignee state in Linear.
- **Milestone scope**: every ticket cited in the Notes block must belong to the named active milestone of the named project.
- **Lead/membership claim**: if the milestone-review names the user as project lead, verify against the actual project record.
- **Email/meeting trace**: every email-sourced checklist row must trace back to a real Gmail message from Phase 1; every meeting row to a real calendar event from Phase 1.
- **Recommended next-work order**: each recommendation's stated reason ("blocks X", "first sub-task of Y") must hold up against the cited relations.

Apply every correction the agent surfaces. Do not write the page while open contradictions remain. Once clean, write the page.
