## Phase 0 — Resolve Arguments

`$ARGUMENTS` should contain:
1. A **Notion database URL** for the Daily ToDo database (e.g., `https://www.notion.so/...`)

If missing, ask the user before proceeding. Once present:
- **Fetch the Notion database** using the URL to discover its data source ID (look for the `<data-source url="collection://...">` tag in the fetch result). Use this data source ID for all subsequent Notion queries and the page update.
