---
model: haiku
name: log-on-call
description: Log an off-hours on-call incident to the daily Notion doc. Finds-or-creates the day's entry with Day Type "On Call" and records a timeline of the actions taken to resolve the issue, in a form useful for post-mortems. Use when paged outside business hours on a day you don't normally work.
---

# Log On-Call

Record an on-call incident handled during non-business hours to the Daily ToDo Notion database. The output is a timeline future-Sam (and a post-mortem) can reconstruct the incident from.

`$ARGUMENTS` should contain a **Notion database URL** for the Daily ToDo database. It may optionally also contain a **date** (`YYYY-MM-DD`) for the incident day — default to today if absent. (Use the date the page was *triggered*; if you were paged before midnight and resolved after, use the date you were first paged.) If the database URL is missing, ask the user before proceeding. Fetch the database URL to discover its data source ID (look for the `<data-source url="collection://...">` tag). Use this data source ID for all subsequent queries and page creation.

## Step 1 — Reconstruct the Incident

Gather what actually happened, in order. Pull from the conversation, and where relevant from git, Linear, GitHub, and any incident tooling the user points at:

- **Trigger** — when the page fired and the symptom (alert name, error, who reported it).
- **Timeline** — the ordered actions taken: what was investigated, what was ruled out, what was changed, when. Capture timestamps where known.
- **Resolution** — root cause if identified, the mitigation/fix applied, and when service was restored.
- **Follow-ups** — anything deferred to business hours (tickets to file, permanent fixes, monitoring gaps).

Do not invent timestamps or causes. If a time or root cause is unknown, say so ("root cause not yet confirmed") rather than guessing.

## Step 2 — Find or Create the Day's Page

Fetch the Daily ToDo database in **view mode** (sorted descending by Date, `page_size: 5`, pick the entry whose `date:Date:start` matches the incident date — per the daily-summary `Notion SQL date-filter` gotcha; do not use SQL mode).

- **If no page exists for that date**, create it with `notion-create-pages` using the resolved data source ID:
  - Properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "On Call".
  - Content: empty `## Checklist`, `## Actions and decisions`, `## Notes`, and `## Summary` sections.
- **If a page already exists** (e.g., an incident landed on a normal workday), append to it — **do not** overwrite its `Day Type` or existing content. The incident timeline is added alongside whatever is already there.

## Step 3 — Log the Timeline

Write the incident into the page's **## Actions and decisions** section via `notion-update-page` with `update_content`, appending (not replacing) if the section already has content. If logging a second incident on the same day, start a new block — never merge two incidents into one timeline.

Shape — one timestamped line per step, oldest first:

```
- 23:14 paged: API 5xx spike on checkout (PagerDuty <link>)
- 23:20 confirmed scope: only the EU region, ruled out a deploy (last deploy 6h prior)
- 23:35 root cause: connection pool exhausted after upstream latency spike
- 23:38 mitigated: raised pool ceiling and recycled the affected pods
- 23:45 resolved: 5xx rate back to baseline, confirmed on dashboard <link>
- follow-up: file ticket to add pool-saturation alert + autoscale (deferred to business hours)
```

Rules:
- **Timestamps lead each line** where known; drop the timestamp only when genuinely unknown.
- **Refs in parens** — PagerDuty/incident links, dashboards, PR/commit, Linear ticket. Never embed mid-sentence.
- **One step per line.** Investigation, mitigation, and resolution are separate lines.
- **End with the resolution line and any follow-ups.** Follow-ups deferred to business hours each get their own `follow-up:` line so they're easy to lift into a ticket later.
- Keep each line scannable — what happened, not a paragraph on how.

Leave `## Notes` and `## Summary` empty. Tomorrow's `daily-summary` reviews this page, writes the post-mortem-flavored `## Summary`, and flips `Status` to Complete.

## Step 4 — Confirm

Tell the user in one line what was logged and to which date's page (and whether the page was created or appended to).

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
