---
model: opus
name: my-workflow
description: "Run research through analysis autonomously, resolving decisions with the pipeline's own recommendation, then stop once at a Decisions Checkpoint to present every artifact and provisional decision for confirm/override. Only after that confirmation does the pre-implementation coordination check run, followed by the gated atomic implement -> validate -> review block. Never jump straight to implementation unless the ledger marks all prior stages complete and decisions confirmed."
disable-model-invocation: true
---

# My Workflow

Run the complete delivery pipeline as resumable stage work while keeping decisions user-owned and factual work agent-owned. Stages 1-8 (research through analyze) run back-to-back, no stop: factual questions are researched, genuine decisions get the pipeline's own recommendation and log as provisional instead of asked live. It stops once after stage 8 — the **Decisions Checkpoint** — presenting every artifact and provisional decision for confirm/override; this is the intended point to clear context. Only after resume does stage 9 (pre-implementation coordination check) run; it stops again only on a sibling overlap, else flows into the atomic execution/review block: `my-implement` -> `my-validate` -> `my-review`. Details: `references/protocol.md`.

Default to `my-research` on a new workflow. Do not infer permission to implement from task wording, an existing plan-looking file, or confidence. Implementation requires research/spec/clarify/architecture-plan/plan/observe/analyze complete, eval-plan complete or `not_applicable`, every provisional decision confirmed at the Decisions Checkpoint, and the pre-implementation coordination check `passed` — run fresh, after confirmation, never before.

If intake identifies the work belongs in `my-quick` instead of the full pipeline, create/update the workflow ledger first. Record `route: my-quick`, the reason, the expected scope, and the exact handoff command before invoking or recommending `my-quick`.

## Load Rules

Read first:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/model-escalation.md`

Use `~/.agents/rules/` when running through Codex.

Load targeted references as needed:

- `references/stage-routing.md` when starting or resuming.
- `references/checkpoint-policy.md` before the Decisions Checkpoint and the atomic block's final checkpoint.
- `references/cross-workflow-coordination.md` at intake, stage 9 (post-checkpoint), and the atomic block's final checkpoint, when the task is a Linear issue.
- `references/autonomy-boundaries.md` when a stage wants to ask questions.
- `references/post-review-loop.md` after `my-review`.
- `references/final-report.md` before final handoff.

## Pipeline

1. `my-research` 2. `my-spec` 3. `my-clarify` 4. `my-architecture-plan` 5. `my-plan` 6. `my-observe` 7. `my-eval-plan` (or ledger `not_applicable`) 8. `my-analyze`.

Stages 1-8 run back-to-back, no stop; every decision gets a recommendation, logs as provisional, run continues. **Decisions Checkpoint** after stage 8: present every artifact and provisional decision for confirm/override — the point to clear context; resume re-enters via the ledger.

9. Pre-implementation coordination check (Linear issues only), run only after that checkpoint: fresh sibling scan against the finalized plan. Stop only on overlap; otherwise straight into the atomic block.
10. Gated atomic block: `my-implement`, fix loop, then checkpoint.
11. Fix loop (automatic): `my-validate` -> `my-review` -> `address-pr-feedback local` if warranted -> repeat, up to 3 iterations. Checkpoint after final review.

## Flow

1. Detect the current git branch and find a ledger whose `branch` matches; fall back to Linear ID/slug/topic on the default branch or no match.
2. Establish task once (a branch-matched ledger's task wins, no confirmation needed).
3. Read or create `~/.claude/thoughts/shared/workflows/<slug>.md`, recording the branch.
4. Loose artifacts are evidence for a stage, never permission to skip it.
5. Decide full pipeline vs. `my-quick`; ledger the decision before handoff.
6. Run every incomplete stage from `references/stage-routing.md`, back-to-back through stage 8. Run stage 9 and the atomic block only after the checkpoint is confirmed.
7. Update the ledger silently after each stage: status, artifacts, assumptions, provisional decisions.
8. Stop once, after stage 8, with the consolidated Decisions Checkpoint.
9. On resume: confirmed decisions run stage 9, then (if clear) the atomic block; an override re-runs only invalidated stages; a stage-9 overlap stops separately for that one decision.

Factual questions are researched; decisions get a recommendation, logged provisional, confirmed at the checkpoint rather than asked live. Validated phases/fixes commit locally; no pushes, PRs, or remote changes unless requested.

## Output

At the Decisions Checkpoint, a stage-9 overlap stop (if any), and the atomic block's end: completed stages, artifact paths, every provisional decision (options, recommendation, evidence) for confirm/override, assumptions, next stage, resume command, and whether context can be cleared safely.
