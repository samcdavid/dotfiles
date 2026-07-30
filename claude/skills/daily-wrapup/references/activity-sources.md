# Activity Sources

Four independent activity feeds for the target day, run in Phase 1 in place of manually logging work throughout the day (`log-work`). Each is best-effort: an empty result means "nothing found," not "the source is broken" — don't block the wrapup on any one of these coming back empty.

Run all four in parallel. Feed the combined output into Phase 2 (Linear enrichment), Phase 3 (Linear Updates block), Phase 4 (Actions and Decisions), and Phase 5 (Notes) exactly as today's raw Notion bullets, calendar, and Gmail context already are.

## 1. GitHub

Run `scripts/github-activity.sh [YYYY-MM-DD]` (defaults to today). It prints a markdown report grouping every PR touched today (opened/merged/reviewed/commented, with the review verdicts) plus every commit authored today, across all repos — sourced from the authenticated user's GitHub events feed, not `gh search ... --updated`, because `--updated` reflects the PR's last-touch time by *anyone*, not a per-day filter on this user's own actions.

Known limitation: GitHub's events feed caps at roughly 300 events over the last ~90 days. On an unusually high-volume day the script may miss early events once the cap is hit mid-page — treat it as a best-effort digest, not an audit log.

## 2. Linear

Reuses the existing Phase 1 Linear gather (`list_issues` with `assignee: "me"` and `updatedAt: "-P1D"`, plus a pass for tickets not assigned to me where I commented or transitioned status — best signal: comments authored by me today, PR links surfaced by the GitHub source above). See Phase 2 for the per-ticket enrichment via `get_issue` that turns this into the change-map used to draft the Linear Updates block.

## 3. Notion

Notion's search does not expose a "last edited by me" filter, so this source only reliably catches **pages I created today** — comments added to, or edits made on, someone else's existing page won't surface here. Today's own Daily ToDo page (already fetched in Phase 1, item 1) is the other half of Notion coverage; between the two, most same-day Notion output is caught, but note the gap rather than presenting this as exhaustive.

1. Resolve your own Notion user ID once per run: `notion-get-users` with `user_id: "self"`.
2. `notion-search` with `query_type: "internal"`, an empty/broad `query`, and `filters: {created_by_user_ids: [<self id>], created_date_range: {start_date: <DATE>, end_date: <DATE+1>}}`. Keep `page_size` small (5-10) — this is a digest, not a full-text trawl.
3. For each result, the search highlight is usually enough context; fetch the full page only if the highlight doesn't explain what it is.

## 4. Slack

`slack_search_public_and_private` searches messages across public channels, private channels, and DMs the user can see — it requires user consent (the runtime will prompt).

1. Read the acting user's Slack `user_id` from the tool's own description at call time (it states "Current logged in user's user_id is U…" directly) — do not hardcode an ID in this file, it is environment-specific and can change across reconnects.
2. Call with `query: "from:<@USER_ID> on:<DATE>"`, `sort: "timestamp"`, `sort_dir: "asc"`, `include_context: false` (reduce noise — we want a list of what was said, not surrounding threads), `limit: 20`.
3. If the day's message count looks truncated at the limit, note that in the wrapup rather than silently treating the 20 as complete.

This surfaces messages *sent* today. It does not catch threads where others acted on something I said earlier, or DMs sent to me — those aren't "my work log" and are out of scope here.
