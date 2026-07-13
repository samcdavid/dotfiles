---
model: sonnet
name: log-on-call
description: Log an off-hours on-call incident to the daily Notion doc. Finds-or-creates the day's entry with Day Type "On Call" and records a timeline of the actions taken to resolve the issue, in a form useful for post-mortems. Use when paged outside business hours on a day you don't normally work.
---

# Log On-Call

Record an on-call incident handled during non-business hours to the Daily ToDo Notion database. The output is a timeline future-Sam (and a post-mortem) can reconstruct the incident from.

`$ARGUMENTS` should contain a **Notion database URL** for the Daily ToDo database. It may optionally also contain a **date** (`YYYY-MM-DD`) for the incident day — default to today if absent. (Use the date the page was *triggered*; if you were paged before midnight and resolved after, use the date you were first paged.) If the database URL is missing, ask the user before proceeding. Fetch the database URL to discover its data source ID (look for the `<data-source url="collection://...">` tag). Use this data source ID for all subsequent queries and page creation.
