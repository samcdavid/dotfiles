# Cross-Workflow Coordination

Load at Step 0 intake and again at every stop in `references/checkpoint-policy.md`'s stop list: the Decisions Checkpoint (after stage 9), stage 10's Pre-Implementation Gate (run only after that checkpoint is confirmed), and the atomic block's final checkpoint after review. Stages 1-9 no longer stop, so there is no per-stage re-check between them. This workflow's task may share a Linear project or milestone with other in-progress work; staying blind to that is how two workflows collide on the same files or ship contradictory behavior.

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
- **Overlap found (file/module or requirement/scope)**: this is a genuine decision, not a fact — log it under the ledger's `## Provisional Decisions` section using the Blocking-Question Protocol format, and continue rather than stopping mid-stage:
  > Cross-workflow overlap at **[stage]**: sibling issue **[ID/title]** (**[ledger stage/status, or "no ledger, status: X"]**) shares **[files/functions | requirement: Y]** with this work. Options: **[sequence after it / define a shared coordination interface / proceed independently and accept the risk]**. My recommendation: **[...]** because **[evidence]**.

  It surfaces at the checkpoint that follows this stage — at intake, that's the confirm-mode message; at stage 10, that's its own small overlap stop; at the atomic block's final check, that's the final report. Wait for the user's call before continuing past whichever checkpoint that is. Record the resolution in the ledger's `cross_workflow` note.

## Pre-Implementation Gate

This check also runs as its own pipeline stage — after the Decisions Checkpoint (stage 9's stop) is confirmed, and before `my-implement` starts. **It must not run any earlier than that** — not during stages 1-9, and not folded into the Decisions Checkpoint's own output. It is the last checkpoint before code changes land, and the most precise one, because the plan is now finalized, its exact surfaces are known, and the user has already signed off on every decision from stages 1-9. Re-run Steps 1-4 above with two changes:

- Compare against the plan's actual surfaces, not just the spec's stated scope — spawn `codebase-locator`/`codebase-analyzer` against the plan file itself to extract the exact files, functions, and schemas it will touch.
- Re-query sibling ledgers and Linear issues fresh. Do not reuse an earlier checkpoint's result — a sibling may have advanced a stage or landed commits since then.

This is a mandatory gate, not optional context: `my-implement` cannot start until it has run for the current plan version, after the Decisions Checkpoint. Record `pre_implementation_check: passed` (no overlap) or `pre_implementation_check: overlap_pending` (escalated, awaiting the user's decision) in the ledger's `cross_workflow` section — a missing or `not_run` value blocks the implementation gate the same way an incomplete stage does.

Escalation follows the same bar as Step 5 for *what counts* as an overlap worth flagging — only an actual file/module or requirement/scope overlap. Unlike stages 1-9, this gate's stop is conditional: if clear, ledger `passed` and continue straight into `my-implement` with no separate stop — every other decision already got its confirmation at the Decisions Checkpoint, so there's nothing left to bundle this with. If overlap is found, stop with just that one decision.

The standing per-checkpoint re-check (Steps 1-5 above) still applies once more at the atomic block's own final checkpoint after review — implementation can take a while, and siblings can change during it.

## Ledger fields

Record under a `cross_workflow` section in the ledger:

```
linear_project_id: ...
linear_project_name: ...
linear_milestone_id: ...        # if set
siblings_checked: [ISSUE-1 (ledger: stage X), ISSUE-2 (no ledger, status: In Progress), ...]
overlaps_found: [none | list with resolution]
pre_implementation_check: not_run | passed | overlap_pending
```

## What this is not

This is not `team-plan` — it doesn't build a wave assignment or conflict matrix for a whole milestone. It's a lightweight, per-checkpoint check so a single-issue workflow doesn't drift into collision with sibling work. If the overlap looks like it needs real multi-issue sequencing (several HIGH conflicts, more than one or two siblings actively in flight), say so and suggest the user run `team-plan` on the milestone instead of resolving it inline.
