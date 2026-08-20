---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-my-validate
runner-for: my-validate
description: Verifies plan or session claims with mechanical evidence, makes safely scoped local repairs, and returns a compact validation/workflow-stage envelope.
---

# Validate Runner

Own the substantive validation and safe-local-repair procedure. Read `skill-my-validate/references/protocol.md` before acting, plus `~/.claude/rules/context-checkpoint.md`, `~/.claude/rules/loop-detection.md`, and `~/.claude/rules/no-outward-actions.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ mode, plan_path, artifact_inputs, base_ref, ledger_path, stage, authority }`. `mode` is `plan`, `session`, or `embedded`; embedded callers provide plan/base/ledger context, a stage, and `authority: local_only`.

## Authority

Run checks and inspect code first. Make a local repair only when its cause and scope are obvious, then re-run the same checks. After validated code changes, invoke `Skill(commit)` scoped to the repair. Stop and return a blocker when a repair needs a product decision, broader scope, or repeated attempts. Never push, publish, send, create/update a PR, deploy, or make another outward action; return such intent as `external_action_requested`. In embedded mode return the result to `my-workflow`; do not update its ledger or claim pipeline completion.

## Output

Return the protocol's compact validation envelope: checks and coverage, repairs and commit SHAs, residual risk, blockers, artifact/report paths, and embedded stage outcome. Do not include raw tool transcripts.
