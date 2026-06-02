---
model: sonnet
name: daily-wrapup
description: End-of-day companion to daily-summary. Consolidates today's Notion entry — identifies what was accomplished, summarizes Linear ticket activity, and rewrites the Actions/Decisions and Notes sections for readability.
disable-model-invocation: true
---

# Daily Wrapup

End-of-day workflow that closes out today's Daily ToDo page. Read-only on Linear — does not transition ticket states, just summarizes what changed. Read/write on the Notion page — rewrites Actions/Decisions and Notes for clarity and adds a Linear Updates block.

Tomorrow's daily-summary will still own writing the **Summary** section and setting the page **Status** to Complete. This skill stays out of those.

## Phase 0 — Resolve Arguments

`$ARGUMENTS` should contain:
1. A **Notion database URL** for the Daily ToDo database (e.g., `https://www.notion.so/...`)

If missing, ask the user before proceeding. Once present:
- **Fetch the Notion database** using the URL to discover its data source ID (look for the `<data-source url="collection://...">` tag in the fetch result). Use this data source ID for all subsequent Notion queries and the page update.

## Phase 1 — Gather Context

Fetch all of the following in parallel:

1. **Notion**: Fetch today's entry from the Daily ToDo database using **view mode** (sorted descending by Date, `page_size: 5`, pick the top result whose `date:Date:start` matches today — per the daily-summary `Notion SQL date-filter` gotcha; do not use SQL mode). Then fetch the page contents in full — Checklist, Actions and decisions, Notes — that is the raw state we will consolidate.

2. **Linear — my activity today**: List issues assigned to me with `updatedAt: "-P1D"` to capture today's churn. Scope per the `list_issues` gotcha to keep results bounded. Also list issues NOT assigned to me where I commented, transitioned status, or had a PR linked today (best signal: recent comments authored by me, plus PR links from today's GitHub activity in Phase 1.4).

3. **Google Calendar**: Today's events — which ran, which were canceled, what was added late. This tells us what consumed today's focus time.

4. **Gmail**: Messages I sent today (Sent folder, today's date) and notable inbound replies that completed an action.

5. **GitHub** (optional): PRs I opened, reviewed, or merged today (`gh search prs --author @me --created today` and `gh search prs --reviewed-by @me --updated today`, or equivalent). Skip if the user is not actively in code today.

## Phase 2 — Enrich Linear

For every Linear issue surfaced in Phase 1 — and every Linear ticket ID mentioned in today's Notion page (Checklist, Actions, Notes) — call `get_issue` and capture:
- Current status and `state.type`.
- Any state transitions visible from today's activity (look at the issue's history / comments / linked PRs to identify what changed *today*, not just current state).
- PR links and their merge/open state.
- Comments authored by me today.
- Blockers added or resolved today.

The output of this phase is a per-ticket change map: morning-state (or last-known prior state) → current state, plus today's work and references.

## Phase 3 — Draft Linear Updates Block

For each ticket with material activity today, draft one entry. Order by significance (Done > Status transition > In-progress work > Comments only), not chronologically. Tickets you merely viewed (no authored activity, no transition) do **not** belong here.

Entry shapes:
- **Status transition**: `MCP-44 — Backlog → In Progress; PR opened (https://github.com/.../1234)`
- **Shipped**: `MCP-32 — In Review → Done; merged 18:06 (https://github.com/.../1230)`
- **In-progress work**: `MCP-40 — still In Progress; scoped into sub-tasks MCP-50 / MCP-51 / MCP-52`
- **Review/comment activity**: `MCP-12 — left review on PR #1234 (changes requested)`
- **Blocked/unblocked**: `MCP-77 — unblocked by MCP-32 merge; now ready to start`

Do **not** fabricate transitions. If a ticket was touched but its status didn't change, write the actual shape ("still In Progress; …") — never invent a transition that didn't happen.

## Phase 4 — Draft New Actions and Decisions

Rewrite the **## Actions and decisions** section by consolidating today's raw bullets:
- Lead with what was done or decided.
- One line on *why* if non-obvious (constraint, stakeholder ask, blocker resolution).
- References inline — PR link, ticket ID, file, person.
- Drop redundancy — fold three bullets describing the same decision into one.
- Group by area/initiative, not chronology.
- **Promote** items from Notes that turned into actions during the day (they belong here, not in Notes).

Do not fabricate. If the day's Actions section was empty or sparse, the rewrite stays sparse. Don't invent entries from calendar/Linear context unless they were real outcomes you can point at.

## Phase 5 — Draft New Notes

Rewrite the **## Notes** section:
- **Keep**: observations, things-to-remember, unresolved threads, learnings worth carrying forward to tomorrow.
- **Drop the morning's milestone-review block**: it was written by daily-summary as forward-looking planning context for *today*. At EOD it is stale and belongs in the day's history (the page itself), not in tomorrow-facing Notes. Strip it out unless an item is still actively relevant tomorrow.
- **Drop**: items that got resolved during the day (those belong in Actions and Decisions or Linear Updates).
- **Promote** out: items that became Actions/Decisions (move them up to Phase 4's section).
- **Add**: brief end-of-day reflections worth carrying forward — patterns spotted, things to revisit tomorrow, open questions that surfaced.

## Phase 6 — Adversarial Verification

Before writing anything to Notion, dispatch the `adversarial-debate` agent (via the `Agent` tool, `subagent_type: "adversarial-debate"`) with:
- The drafted Linear Updates block (Phase 3).
- The drafted Actions and Decisions section (Phase 4).
- The drafted Notes section (Phase 5).
- The full list of Linear ticket IDs, PR links, decisions, people, and meetings cited.

The agent must independently re-verify, not trust the drafts:

- **Status transitions**: every `X → Y` claim must match the actual Linear history for that ticket *today* (agent re-fetches with `get_issue` and inspects today's activity). Tickets claimed as transitioned but actually unchanged in Linear get corrected.
- **Shipped claims**: a ticket claimed as `Done`/`merged` must have `state.type` of `completed` *and* a merged PR linked. A claimed merge timestamp must fall within today's date.
- **PR claims**: every PR link resolves; the PR is actually linked to the cited ticket; open/merge times are today's.
- **Action attribution**: every Action/Decision entry traces to a real artifact gathered in Phase 1 — a PR, a Linear comment, a Notion entry, a calendar event, a Gmail message. No phantom actions.
- **Decision provenance**: each "decided X" entry traces to a real source (a comment, a meeting outcome, a thread). Not fabricated narrative.
- **Drop checks**: nothing from the morning's milestone-review block should leak into the rewritten Notes unless tomorrow-relevant. Anything that *was* an open question this morning and is now resolved should appear in Actions/Decisions, not Notes.

Apply every correction the agent surfaces. Do not write the page while open contradictions remain.

## Phase 7 — Write to Notion

Update today's Notion page using `notion-update-page` with `update_content`:
- Replace **## Actions and decisions** with the Phase 4 draft.
- Replace **## Notes** with the Phase 5 draft.
- Add (or replace, if it already exists) a **## Linear Updates** section positioned after Notes, containing the Phase 3 draft.

Do **not** touch:
- **## Checklist** — today's historical record of what was planned. Stands as-is.
- **## Summary** — tomorrow morning's daily-summary writes this in performance-review tone.
- Page `Status` property — tomorrow's daily-summary flips it to `Complete` after the Summary is written.

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
