# Gotchas — start-day

Known failure patterns and lessons learned. Read before starting work with this skill.

### Enrich all assigned issues, not just those referenced in yesterday's notes
- **Category:** convention
- **Context:** Phase 2 (Enrich) and Phase 5 (Build Today's Checklist) of the start-day workflow.
- **Wrong:** Only fetching `get_issue` for tickets that appear in yesterday's Notion entry, then writing today's checklist primarily from yesterday's leftovers and today's calendar.
- **Right:** Pull **every** issue currently assigned to the user (across started, unstarted, and backlog states) and call `get_issue` on each to verify current status, blocked/blocking relations, and PR state. Then look at the **projects** those issues belong to — read the project description/milestones to understand priorities and what should be picked up next. Use that combined picture (assigned issues + project priorities) to drive today's checklist, not just yesterday's residual work.
- **Why:** Yesterday's notes are a backward-looking lens — they show what was already in flight. Today's planning needs a forward-looking lens: what's assigned that hasn't been touched, which project milestones are approaching, and what should be next-up. If `list_issues` returns empty or unexpected results, treat that as a signal to broaden the query (drop the state filter, check the user's lead/membership across projects) rather than skipping the step.
- **Source:** Observed when the daily update and checklist were written almost entirely from yesterday's PR-review log + meetings, missing forward-looking context from in-progress assignments and active project milestones.

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

### Daily-update bullets must be one sentence; context belongs in Notes
- **Category:** convention
- **Context:** Phase 4 (Draft Daily Update) and Phase 5 (Build Today's Checklist) — writing the Y:/T:/PL: bullets and the `## Checklist` rows.
- **Wrong:** Packing the evidence into the bullet itself. Real example from a checklist row: "MCP-517 — clear the blocking finding on #27847. Two CHANGES_REQUESTED reviews open on the same defect: two reviewers (8/8 17:25Z and 8/10 09:04Z). `Question.id`, `Part.id`, and `AuthoredDiaryGroup.question_ids` are `AuthoredSymbol`, but every fixture passes a bare `str`; the dataclasses have no `__post_init__`, so both sides of `diary_rules.py:128`'s comparison agree on a type production never uses. Sites: …" — one bullet, six sentences, ~120 words.
- **Right:** One sentence per bullet, ending at the action and its identifier: "MCP-517 — fix the `AuthoredSymbol` fixture drift blocking #27847." Keep the item's primary link inline — the PR, ticket, or doc the row is *about* is what makes a checklist row clickable, and burying it in Notes defeats the point. Move everything else (reviewer names, timestamps, file:line lists, reproduction detail, caveats, secondary links) into the page's `## Notes` section under a heading that names the ticket. A daily-update bullet that needs a second sentence is a signal the detail belongs in Notion, not in the update itself.
- **Why:** Both artifacts are scanned, not read. A daily-update reader wants to know what moved and what's next in one pass; a checklist is a list of what to do, and prose inside a checkbox makes the list unscannable and hides how many items there actually are. Note this deliberately overrides the "include enough context to act on them" instruction in Phase 5 step 3 of `~/.claude/agents/skill-start-day/references/protocol.md` — that context is still required, it just lives in Notes rather than inline in the row.
- **Source:** User feedback 2026-08-10 on the daily update and checklist: "each bullet item is too long. Should be no longer than a single sentence. Put additional context in notes."
