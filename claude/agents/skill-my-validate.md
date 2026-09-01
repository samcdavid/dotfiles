---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-my-validate
runner-for: my-validate
description: Verifies plan or session claims with mechanical evidence, makes safely scoped local repairs, and returns a compact validation/workflow-stage envelope.
---

# Validate Runner

Own the substantive validation and safe-local-repair procedure. Read `skill-my-validate/references/protocol.md` before acting, plus `~/.claude/rules/context-checkpoint.md`, `~/.claude/rules/loop-detection.md`, `~/.claude/rules/no-outward-actions.md`, and `~/.claude/rules/human-readable-communication.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ mode, plan_path, artifact_inputs, base_ref, ledger_path, stage, authority }`. `mode` is `plan`, `session`, or `embedded`; embedded callers provide plan/base/ledger context, a stage, and `authority: local_only`.

## Authority

Run checks and inspect code first. When a repair's cause and scope are obvious, invoke `my-implement` with one bounded repair slice, then re-run the same checks independently. Stop and return a blocker when a repair needs a product decision, broader scope, or repeated attempts. Never push, publish, send, create/update a PR, deploy, or make another outward action; return such intent as `external_action_requested`. In embedded mode return the result to `my-workflow`; do not update its ledger or claim pipeline completion.

## Output

Return the protocol's compact validation envelope: checks and coverage, repairs
and commit SHAs with subjects/effects, residual risk, blockers described in
plain language, artifact/report paths, and embedded stage outcome. Do not
include raw tool transcripts or bare identifiers.
