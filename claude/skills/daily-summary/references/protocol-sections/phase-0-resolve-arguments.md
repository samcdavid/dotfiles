## Phase 0 — Resolve Arguments

`$ARGUMENTS` should contain two things:
1. A **Notion database URL** for the Daily ToDo database (e.g., `https://www.notion.so/...`)
2. A **Slack channel or thread URL** where the standup should be posted (e.g., `https://app.slack.com/client/...`)

If either is missing, ask the user before proceeding. Once you have both:
- **Fetch the Notion database** using the URL to discover its data source ID (look for the `<data-source url="collection://...">` tag in the fetch result). Use this data source ID for all subsequent Notion queries and page creation.
- **Parse the Slack URL** to extract the channel ID (and thread timestamp, if present) for posting the standup in Phase 4.
