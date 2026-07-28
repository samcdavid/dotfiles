# Cross-Workflow Coordination

Load at Step 0 intake and again at every checkpoint in `references/checkpoint-policy.md`'s stop list. This workflow's task may share a Linear project or milestone with other in-progress work; staying blind to that is how two workflows collide on the same files or ship contradictory behavior.

## What triggers this

Only when the current task resolves to a Linear issue (given directly, or discovered via a ticket reference). No Linear issue means no project/milestone to coordinate against — skip silently, no note needed.

## Step 1 — Identify the project and milestone

Resolve once at intake via `get_issue` and record in the ledger frontmatter: `linear_issue_id`, `linear_project_id`, `linear_project_name`, and `linear_milestone_id`/`linear_milestone_name` if the issue has one. Reuse the recorded values on later checkpoints instead of re-fetching — the issue's project/milestone doesn't change mid-workflow.

## Step 2 — Sibling ledgers (cheap, do this first)

Scan `~/.claude/thoughts/shared/workflows/` for other ledger files (excluding the current one) whose frontmatter `linear_project_id` matches (and `linear_milestone_id` when the current issue has one). For each match, note its Linear issue ID, current stage, status, and artifact paths. A sibling ledger at `my-plan` or later has a plan/diff worth checking for overlap in Step 4.

## Step 3 — Sibling issues (live Linear query)

Query `list_issues` filtered by the project (and milestone, if set) to find sibling issues. Keep only issues that are not `Done`/`Cancelled` and are not the current issue. A sibling with no matching ledger from Step 2 is work happening outside `my-workflow` — still relevant, note it the same way.

## Step 4 — Overlap check (only when siblings exist)

Do not stop just because a sibling exists — most siblings are unrelated. Check for two kinds of overlap:

- **File/module overlap**: if a sibling's ledger has a plan or diff artifact, compare the surfaces it touches (spawn `codebase-locator`/`codebase-analyzer` scoped to that sibling's plan, or to its issue description if no plan exists yet) against this workflow's own surfaces at the current stage (its plan, spec, or diff — whichever exists). Flag when both name the same files, functions, or schema.
- **Requirement/scope overlap or conflict**: compare the current spec/plan's stated scope and acceptance criteria against the sibling issue's description/comments. Flag when they duplicate the same deliverable, or state contradictory behavior for the same surface.

This is the same conflict-detection judgment `team-plan` applies across a whole milestone (see that skill's Steps 3-4 for the technique); here it's scoped to just this issue's siblings and run incrementally at each checkpoint rather than as a separate planning pass.

## Step 5 — Log or escalate

- **No siblings, or siblings checked with no overlap found**: log a one-line ledger note — which sibling ledgers/issues were checked, and that no overlap was found. Continue; no stop.
- **Overlap found (file/module or requirement/scope)**: this is a genuine decision, not a fact — surface it at the current checkpoint using the Blocking-Question Protocol format:
  > Cross-workflow overlap at **[stage]**: sibling issue **[ID/title]** (**[ledger stage/status, or "no ledger, status: X"]**) shares **[files/functions | requirement: Y]** with this work. Options: **[sequence after it / define a shared coordination interface / proceed independently and accept the risk]**. My recommendation: **[...]** because **[evidence]**.

  Wait for the user's call before continuing past the checkpoint. Record the resolution in the ledger's `cross_workflow` note.

## Atomic block timing

The atomic execution/review block (stages 8-10) checkpoints only once, at the end. Run this check twice there: once before `my-implement` starts (file-overlap risk is highest right before code changes land) and once more at the final checkpoint after review.

## Ledger fields

Record under a `cross_workflow` section in the ledger:

```
linear_project_id: ...
linear_project_name: ...
linear_milestone_id: ...        # if set
siblings_checked: [ISSUE-1 (ledger: stage X), ISSUE-2 (no ledger, status: In Progress), ...]
overlaps_found: [none | list with resolution]
```

## What this is not

This is not `team-plan` — it doesn't build a wave assignment or conflict matrix for a whole milestone. It's a lightweight, per-checkpoint check so a single-issue workflow doesn't drift into collision with sibling work. If the overlap looks like it needs real multi-issue sequencing (several HIGH conflicts, more than one or two siblings actively in flight), say so and suggest the user run `team-plan` on the milestone instead of resolving it inline.
