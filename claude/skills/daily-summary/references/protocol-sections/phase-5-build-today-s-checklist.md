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
