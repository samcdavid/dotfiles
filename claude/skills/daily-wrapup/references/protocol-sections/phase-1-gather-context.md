## Phase 1 — Gather Context

Fetch all of the following in parallel:

1. **Notion**: Fetch today's entry from the Daily ToDo database using **view mode** (sorted descending by Date, `page_size: 5`, pick the top result whose `date:Date:start` matches today — per the daily-summary `Notion SQL date-filter` gotcha; do not use SQL mode). Then fetch the page contents in full — Checklist, Actions and decisions, Notes — that is the raw state we will consolidate.

2. **Linear — my activity today**: List issues assigned to me with `updatedAt: "-P1D"` to capture today's churn. Scope per the `list_issues` gotcha to keep results bounded. Also list issues NOT assigned to me where I commented, transitioned status, or had a PR linked today (best signal: recent comments authored by me, plus PR links from today's GitHub activity in Phase 1.4).

3. **Google Calendar**: Today's events — which ran, which were canceled, what was added late. This tells us what consumed today's focus time.

4. **Gmail**: Messages I sent today (Sent folder, today's date) and notable inbound replies that completed an action.

5. **GitHub** (optional): PRs I opened, reviewed, or merged today (`gh search prs --author @me --created today` and `gh search prs --reviewed-by @me --updated today`, or equivalent). Skip if the user is not actively in code today.
