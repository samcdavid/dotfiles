---
model: sonnet
name: log-work
description: Log what was accomplished in the current session to the daily Notion doc. Appends brief actions (fixes, implementations, reviews, investigations) to today's entry. Use at the end of a work session or after completing something notable.
---

# Log Work

Append a brief record of what was accomplished in this session to today's entry in the Daily ToDo Notion database.

`$ARGUMENTS` should contain a **Notion database URL** for the Daily ToDo database. If missing, ask the user before proceeding. Fetch the database URL to discover its data source ID (look for the `<data-source url="collection://...">` tag). Use this data source ID for all subsequent queries and page creation.
