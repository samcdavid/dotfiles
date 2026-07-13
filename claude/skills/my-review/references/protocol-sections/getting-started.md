## Getting Started

Determine what to review:
- If `$ARGUMENTS` is `capture` → **Capture Mode** — queue a Learned Miss (see § "Subcommands — `capture`, `promote`"). Skip the rest of this skill.
- If `$ARGUMENTS` is `promote` → **Promote Mode** — walk the pending queue (see § "Subcommands — `capture`, `promote`"). Skip the rest of this skill.
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`).
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review working tree changes via `git diff`).
- If `$ARGUMENTS` contains a branch name → review diff against that branch.

Subcommand keywords (`capture`, `promote`) take precedence over branch-name interpretation.

### Read these before producing any output

- `gotchas.md` — known failure patterns for this skill.
- `references/learned-misses.md` — pattern queue. Auto-promote any pending entries whose Evidence has crossed threshold BEFORE producing the triage block, so the triage block can report what was promoted.
