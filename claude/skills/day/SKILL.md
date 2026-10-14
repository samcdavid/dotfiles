---
name: day
description: "Start or end my workday in my Notion Daily ToDo database: morning brief and checklist, or end-of-day consolidation."
effort: xhigh
---

Notion Daily ToDo database: $ARGUMENTS. If no URL is given, ask for it; never guess one. Fetch it to get the data source ID. Query it in view mode sorted by Date descending (SQL mode 429s). Use the template in `references/page-template.md`.

**Mode:** an explicit "start" or "end" in the arguments wins. Otherwise: no page for today → start; today's page exists and it's afternoon → end; else start (refresh in place).

**Start**
1. For the previous workday and any `On Call` days since, write a `## Summary` (workday: impact and decisions, performance-review tone; on-call: trigger, resolution, follow-ups) and set Status to Complete.
2. Gather in parallel: my Linear issues (always scope with `state` or `updatedAt`; unscoped calls blow the token cap) plus open issues in my projects' active milestones; today's calendar plus PTO/holidays over the next 7 days; actionable work email (prefer the `gws` CLI, fall back to MCP).
3. Create or update today's page: the Daily Update, then a Checklist of what I can have a PR open on by end of day given my meetings, highest priority first. Drop completed or canceled tickets. Notes: Urgent (mine or grabbable), High unassigned bottlenecks, Needs breakdown (over a day), and the next 2–3 tickets with reasons.

**End**
1. Gather today's activity: today's page; my GitHub events (`gh api users/<me>/events`, filtered to today); Linear issues I touched; Notion pages I created; Slack messages I sent; calendar; sent mail.
2. Rewrite `## Actions and decisions`: consolidate, grouped by area, with references inline. Rewrite `## Notes`: drop the morning milestone block and anything resolved; keep threads for tomorrow. Add `## Linear Updates` covering real transitions only.
3. Leave `## Checklist`, `## Summary`, and Status alone; the next start handles them.

Every bullet is one sentence plus its link; detail goes in Notes. Before writing, re-check every status, PR link, and ticket claim against the source, and never invent work. Write only to my own Notion page; never post anywhere else.
