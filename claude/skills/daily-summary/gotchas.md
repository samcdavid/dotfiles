# Gotchas — daily-summary

Known failure patterns and lessons learned. Read before starting work with this skill.

### Enrich all assigned issues, not just those referenced in yesterday's notes
- **Category:** convention
- **Context:** Phase 2 (Enrich) and Phase 5 (Build Today's Checklist) of the daily-summary workflow.
- **Wrong:** Only fetching `get_issue` for tickets that appear in yesterday's Notion entry, then writing today's checklist primarily from yesterday's leftovers and today's calendar.
- **Right:** Pull **every** issue currently assigned to the user (across started, unstarted, and backlog states) and call `get_issue` on each to verify current status, blocked/blocking relations, and PR state. Then look at the **projects** those issues belong to — read the project description/milestones to understand priorities and what should be picked up next. Use that combined picture (assigned issues + project priorities) to drive today's checklist, not just yesterday's residual work.
- **Why:** Yesterday's notes are a backward-looking lens — they show what was already in flight. Today's planning needs a forward-looking lens: what's assigned that hasn't been touched, which project milestones are approaching, and what should be next-up. If `list_issues` returns empty or unexpected results, treat that as a signal to broaden the query (drop the state filter, check the user's lead/membership across projects) rather than skipping the step.
- **Source:** Observed when the standup and checklist were written almost entirely from yesterday's PR-review log + meetings, missing forward-looking context from in-progress assignments and active project milestones.

### Notion SQL date-filter queries can 429; use view mode instead
- **Category:** edge-case
- **Context:** Phase 1 (Gather Context) — fetching yesterday's entry from the Daily ToDo database.
- **Wrong:** `query_data_sources` in SQL mode with a `WHERE "date:Date:start" = ?` predicate (`SELECT * FROM "collection://..." WHERE "date:Date:start" = '2026-05-21'`). Repeatedly returns `Failed to execute query: Something went wrong. (429)` even on the first call of a session, including after narrowing the SELECT to a few columns.
- **Right:** Switch to view mode against the database's default/recent view (sorted descending by Date), `page_size: 5`, and pick the top result whose `date:Date:start` matches the target workday. The view is pre-indexed and reliably returns in one call.
- **Why:** SQL-mode queries against long-lived daily databases appear to trip Notion-internal rate limiting (years of entries to scan); view mode hits a different, indexed code path. Retrying the SQL form just burns time — pivot on the first 429, don't iterate.
- **Source:** Observed when two variations of a date-equality SQL query against a multi-year daily database both returned 429 immediately, while a view-mode query against the same data source succeeded on first try.

### `list_issues` without filters can exceed the token cap
- **Category:** failure-mode
- **Context:** Phase 1 (Gather Context) — listing Linear issues assigned to the user.
- **Wrong:** `list_issues(assignee="me", limit=50)` with no state or updatedAt filter. For heavy assignees this can return 70k+ characters and get redirected to a file, breaking parallel-tool composition for downstream steps.
- **Right:** Always scope the call. Either `state: "started"` for what's actively in progress, `updatedAt: "-P3D"` for recently-touched issues, or both calls in parallel for full coverage. Keep `limit` ≤ 30 unless you've confirmed the assignee is light.
- **Why:** Long-tenured assignees accumulate large backlogs (started + unstarted + triage). The unscoped dump is unparseable in-band and forces a follow-up retry, costing a parallel-tool round trip.
- **Source:** Observed when an unscoped `list_issues(assignee="me")` returned 76,668 characters and was redirected to a tool-results file, while a parallel `state="started"` call succeeded inline.
