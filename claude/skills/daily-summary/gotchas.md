# Gotchas — daily-summary

Known failure patterns and lessons learned. Read before starting work with this skill.

### Enrich all assigned issues, not just those referenced in yesterday's notes
- **Category:** convention
- **Context:** Phase 2 (Enrich) and Phase 5 (Build Today's Checklist) of the daily-summary workflow.
- **Wrong:** Only fetching `get_issue` for tickets that appear in yesterday's Notion entry, then writing today's checklist primarily from yesterday's leftovers and today's calendar.
- **Right:** Pull **every** issue currently assigned to the user (across started, unstarted, and backlog states) and call `get_issue` on each to verify current status, blocked/blocking relations, and PR state. Then look at the **projects** those issues belong to — read the project description/milestones to understand priorities and what should be picked up next. Use that combined picture (assigned issues + project priorities) to drive today's checklist, not just yesterday's residual work.
- **Why:** Yesterday's notes are a backward-looking lens — they show what was already in flight. Today's planning needs a forward-looking lens: what's assigned that hasn't been touched, which project milestones are approaching, and what should be next-up. If `list_issues` returns empty or unexpected results, treat that as a signal to broaden the query (drop the state filter, check the user's lead/membership across projects) rather than skipping the step.
- **Source:** Observed when the standup and checklist were written almost entirely from yesterday's PR-review log + meetings, missing forward-looking context from in-progress assignments and active project milestones.
