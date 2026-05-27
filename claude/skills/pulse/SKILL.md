---
name: pulse
description: Project pulse — digest of recent codebase activity across all contributors. Surfaces hot areas, significant changes (migrations, new modules, API shifts, dependency updates), and per-author summaries. Default 1 week, configurable via argument. Delegates gathering/synthesis to the `pulse-aggregator` agent.
---

# Project Pulse

Generate a concise briefing of recent project activity so I can stay current without reading every commit and PR. The gathering and synthesis runs inside the `pulse-aggregator` agent — this skill just parses the time range, checks tool availability, spawns the agent, and presents what it returns.

## Step 1 — Parse arguments

`$ARGUMENTS` controls the time range:
- If `$ARGUMENTS` is a number (e.g. `3`), treat as number of days.
- If `$ARGUMENTS` is a duration string (e.g. `2w`, `1m`), parse accordingly.
- If `$ARGUMENTS` is empty, default to **7 days**.
- If `$ARGUMENTS` contains a date (e.g. `2026-04-01`), use "since that date".

Convert the parsed value to:
- `since`: an ISO date or `git log --since` compatible string
- `range_label`: human-readable label for the output title (e.g. `"last 7 days"`, `"since 2026-04-01"`)

## Step 2 — Check tool availability

Determine which enrichment sources are reachable:

- `repo_has_gh_remote`: `gh repo view` exits 0 AND `gh auth status` shows authenticated.
- `linear_available`: a Linear MCP tool (e.g. `mcp__linear-server__list_teams`) is in the tool list.
- `notion_available`: a Notion MCP tool (e.g. `mcp__notion__notion-search`) is in the tool list.

## Step 3 — Spawn the aggregator

Invoke the `pulse-aggregator` agent with the bundle:

```
- since
- range_label
- repo_has_gh_remote
- linear_available
- notion_available
```

The agent runs git history queries, GitHub PR queries, migration scans, dependency-change scans, and (when MCPs are available) Linear and Notion enrichment in parallel. It returns a finished briefing.

If the agent returns an `## Error` block, surface it and stop.

## Step 4 — Present the briefing

Display the agent's output verbatim. Do not re-synthesize or add commentary — the agent has already produced the final artifact.

## Constraints

- Do not spawn additional research agents from main context — the aggregator owns the work.
- Do not commit anything to the repo. Pulse is read-only.
