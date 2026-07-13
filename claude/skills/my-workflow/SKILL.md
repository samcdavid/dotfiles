---
model: opus
name: my-workflow
description: Run one checkpointed delivery stage at a time: research, spec, clarify, plan, observe, analyze, then the gated atomic implement -> validate -> review block. Never jump straight to implementation unless the workflow ledger explicitly marks all prior stages complete.
disable-model-invocation: true
---

# My Workflow

Run the complete delivery pipeline as resumable stage work while keeping decisions user-owned and factual work agent-owned. Stop after each major stage so the user can review output, clear context, and resume from the workflow ledger. The exception is the gated atomic execution/review block: `my-implement` -> `my-validate` -> `my-review`.

Default to `my-research` on a new workflow. Do not infer permission to implement from the user's task wording, an existing plan-looking file, or the assistant's confidence. Implementation is allowed only when the workflow ledger explicitly marks research, spec, clarify, plan, observe, and analyze complete, and the user has resumed after the plan/analysis checkpoints.

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
- `references/checkpoint-policy.md` before ending any stage.
- `references/autonomy-boundaries.md` when a stage wants to ask questions.
- `references/post-review-loop.md` after `my-review`.
- `references/final-report.md` before final handoff.

## Pipeline

1. `my-research` -> checkpoint.
2. `my-spec` -> checkpoint.
3. `my-clarify` -> checkpoint.
4. `my-plan` -> checkpoint.
5. `my-observe` -> checkpoint.
6. `my-analyze` -> checkpoint.
7. Gated atomic block: `my-implement` -> `my-validate` -> `my-review` -> checkpoint.
8. Post-review fix iteration when resumed: `address-pr-feedback` -> `my-validate` -> `my-review` -> checkpoint.

## Flow

1. Establish task once from arguments, conversation, ticket, file, or URL.
2. Read or create `~/.claude/thoughts/shared/workflows/<slug>.md`.
3. Detect existing workflow ledger first; use loose artifacts only as evidence to attach to a stage, not as permission to skip uncompleted stages.
4. Decide whether to route to the full pipeline or `my-quick`; ledger the decision before any handoff.
5. Pick earliest incomplete stage from `references/stage-routing.md`.
6. Run only that stage, except run the atomic execution/review block as one unit after its gates are satisfied.
7. Update ledger with stage status, artifacts, assumptions, and decisions.
8. Stop with checkpoint output and exact resume command.

Use question policy: factual questions must be researched; genuine decisions go to the user. No commits, pushes, PR creation, or remote state changes unless explicitly requested.

## Output

At every checkpoint return completed stage, artifact paths, decisions/assumptions, next stage, exact resume command, and whether context can be cleared safely.
