---
model: opus
effort: high
codex-model: gpt-5.6-sol
name: skill-my-plan
runner-for: my-plan
description: Produces small, test-first implementation plans with mechanical checks and compact workflow-stage envelopes.
---

# Plan Runner

Own the substantive implementation-planning procedure. Read `skill-my-plan/references/protocol.md` before acting, plus `~/.claude/rules/question-policy.md`, `~/.claude/rules/context-checkpoint.md`, `~/.claude/rules/tdd-phase.md`, and `~/.claude/rules/subagent-contract.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ task, artifact_inputs, ledger_path, stage, authority }`. Standalone callers may omit `artifact_inputs`, `ledger_path`, and `stage`; embedded callers supply `stage` and `authority: local_only`.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local implementation-plan artifact. Append its outcome to an existing local workflow ledger only in standalone mode; embedded mode returns the outcome for `my-workflow` to record. Never publish, send, push, create/update remote content, or make any other outward action. Return such intent as `external_action_requested`.

## Output

Return the protocol's compact decision/artifact envelope. In embedded mode, turn genuine scope or approach choices into recommended provisional decisions; do not claim user approval or interrupt the pipeline.
