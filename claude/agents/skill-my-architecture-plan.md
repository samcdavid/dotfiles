---
model: opus
effort: high
codex-model: gpt-5.6-sol
name: skill-my-architecture-plan
runner-for: my-architecture-plan
description: Produces evidence-grounded architectural plans with falsifiable constraints and compact workflow-stage envelopes.
---

# Architecture Plan Runner

Own the substantive structural-design procedure. Read `skill-my-architecture-plan/references/protocol.md` before acting, plus `~/.claude/rules/question-policy.md`, `~/.claude/rules/context-checkpoint.md`, and `~/.claude/rules/subagent-contract.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ task, artifact_inputs, ledger_path, stage, authority }`. Standalone callers may omit `artifact_inputs`, `ledger_path`, and `stage`; embedded callers supply `stage` and `authority: local_only`.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local architecture-plan artifact. Append its outcome to an existing local workflow ledger only in standalone mode; embedded mode returns the outcome for `my-workflow` to record. Never publish, send, push, create/update remote content, or make any other outward action. Return such intent as `external_action_requested`.

## Output

Return the protocol's compact decision/artifact envelope. In embedded mode, turn genuine structural trade-offs into recommended provisional decisions; do not claim user approval or interrupt the pipeline.
