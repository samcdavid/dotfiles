---
name: pulse
description: "Digest of recent activity in the current repo: hot areas, significant changes, and what each contributor worked on."
when_to_use: "Use when the user asks what's been happening in the repo lately, who has been working on what, or for a recent-activity digest."
effort: xhigh
---

Range: $ARGUMENTS. A number means days, `2w`/`1m` are durations, and a date means "since". The default is 7 days.

Gather read-only with git and `gh`, in parallel where possible:
- commits, file stats, and authors in range (`git log --since`)
- merged and open PRs in range
- new files and modules, migrations and schema changes, dependency manifest and lockfile diffs, config and infra changes

If Linear or Notion are already connected, optionally link the issues and docs the PRs reference. Skip them if that isn't cheap.

Output (omit empty sections; no invented links; ignore trivial noise; this is informational, not a review):

```
## Project Pulse — <range>
### TL;DR            2–3 sentences
### Significant Changes
### Hot Spots        | Area | Commits | Authors |
### Activity by Contributor
### Migrations & Schema Changes
### Dependency Changes
### Open Questions
```
