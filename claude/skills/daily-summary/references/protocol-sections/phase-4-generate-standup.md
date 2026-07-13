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
