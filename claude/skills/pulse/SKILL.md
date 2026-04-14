---
name: pulse
description: Project pulse — digest of recent codebase activity across all contributors. Surfaces hot areas, significant changes (migrations, new modules, API shifts, dependency updates), and per-author summaries. Default 1 week, configurable via argument.
---

# Project Pulse

Generate a concise briefing of recent project activity so I can stay current without reading every commit and PR.

## Parse Arguments

`$ARGUMENTS` controls the time range:
- If `$ARGUMENTS` is a number (e.g. `3`), treat as number of days.
- If `$ARGUMENTS` is a duration string (e.g. `2w`, `1m`), parse accordingly.
- If `$ARGUMENTS` is empty, default to **30 days**.
- If `$ARGUMENTS` contains a date (e.g. `2026-04-01`), use "since that date".

## Phase 1 — Gather Raw Activity

Run all of these in parallel:

### Git History
```bash
git log --since="<range>" --pretty=format:"%H|%an|%ae|%ad|%s" --date=short
git log --since="<range>" --stat --pretty=format:"COMMIT:%H"
git shortlog --since="<range>" -sn --no-merges
```

### GitHub PRs (if `gh` is available and repo has a remote)
```bash
gh pr list --state merged --search "merged:>=<date>" --limit 100 --json number,title,author,mergedAt,labels,additions,deletions,files
gh pr list --state open --json number,title,author,createdAt,labels,additions,deletions
```

### Migrations & Schema Changes
```bash
git log --since="<range>" --diff-filter=A --name-only -- "**/migrations/**" "**/migrate/**" "**/*migration*" "**/schema*"
```

### New Files (modules, services, significant additions)
```bash
git log --since="<range>" --diff-filter=A --name-only --pretty=format:""
```

### Dependency Changes
```bash
git log --since="<range>" -p -- "**/mix.lock" "**/Gemfile.lock" "**/package-lock.json" "**/yarn.lock" "**/poetry.lock" "**/Cargo.lock" "**/go.sum" "**/requirements*.txt"
```

## Phase 2 — Analyze and Classify

### Identify Hot Spots
Rank files and directories by churn (number of commits + lines changed). The top 10 most-changed areas are the "hot spots" — these are where the action is.

### Classify Changes
Categorize all activity into:

| Category | Signal |
|----------|--------|
| **Schema / Migrations** | New migration files, schema changes |
| **New Modules** | New directories, new service files, new test files for new modules |
| **API Changes** | Changes to routes, controllers, resolvers, API schemas, protobuf/GraphQL definitions |
| **Dependency Updates** | Lock file changes, new packages added or removed |
| **Refactors** | Large file renames, moves, or deletions without new features |
| **Config / Infra** | CI/CD, Dockerfiles, deploy configs, environment variables |
| **Bug Fixes** | Commits/PRs with fix/bug/hotfix in the title |

### Per-Author Summary
For each active contributor, summarize:
- Number of commits / PRs
- Primary areas of focus (top 2-3 directories or modules)
- Any notable individual changes worth calling out

## Phase 3 — Enrich with Context

### Linear
Use the Linear MCP tools to pull broader team context:

1. **Identify the team/project**: List Linear teams and projects to find which ones map to this repo. Use project names, repo references, or ask me if ambiguous.
2. **Recent completed issues**: List issues that moved to "Done" or "Merged" status in the time range. These are the canonical "what shipped" — match them against PRs/commits where possible.
3. **In-progress initiatives**: List active projects and their progress. This surfaces what's coming, not just what landed.
4. **Ticket context for significant changes**: For PRs that reference Linear tickets (migrations, new modules, API changes), fetch the ticket description and acceptance criteria to explain *why* the change was made.

### Notion
Use the Notion MCP tools to pull documentation and planning context:

1. **Search for recent pages**: Search Notion for pages created or updated in the time range that relate to this project — RFCs, design docs, architecture decisions, runbooks, post-mortems.
2. **Meeting notes**: Search for recent meeting notes that reference the project, team, or key initiatives. These often contain context that doesn't make it into tickets.
3. **Link docs to changes**: When a significant code change corresponds to an RFC or design doc in Notion, include the link in the briefing so I can read the full rationale.

## Phase 4 — Generate Briefing

Output the briefing in this format:

```markdown
## Project Pulse — [date range]

### TL;DR
[2-3 sentences capturing the most important things to know]

### Significant Changes
[Ordered by impact. Each entry: what changed, who did it, why it matters]

1. **[Category]: [Brief description]** — @author
   [One line of context. Link to PR if available.]

### Hot Spots
[Top 5-10 most active areas with commit/line counts]
| Area | Commits | Authors |
|------|---------|---------|

### Activity by Contributor
[Per-person summary — what they've been focused on]

- **@name** (N commits, N PRs) — [1-line summary of focus areas]

### New Modules & Services
[List of newly created modules/services/directories, if any]

### Migrations & Schema Changes
[List with dates and brief description, if any]

### Dependency Changes
[Notable additions, removals, or major version bumps, if any]

### Open Questions
[Things that look like they might affect you or need awareness — architectural shifts, large refactors in progress, deprecated patterns being replaced]
```

## Constraints

- **Concise over comprehensive** — This is a briefing, not a changelog. Summarize, don't enumerate every commit.
- **Signal over noise** — Skip trivial changes (typo fixes, formatting, minor test additions). Focus on things that would change how someone thinks about the codebase.
- **No judgment** — This is informational, not a review. Don't critique the changes.
- **Omit empty sections** — If there are no migrations, don't include a migrations section.
- **Relative sizing** — Help me understand scale. "12 files changed" means less than "new authentication service added across 12 files."
