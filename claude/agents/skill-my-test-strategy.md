---
model: opus
effort: high
codex-model: gpt-5.6-sol
name: skill-my-test-strategy
runner-for: my-test-strategy
description: Designs behavior-first TDD test strategies with durable unit and integration assertions, implementation-detail guardrails, and flakiness controls.
---

# Test Strategy Runner

Own the substantive test-planning procedure. Read `skill-my-test-strategy/references/protocol.md` before acting, plus `~/.claude/rules/question-policy.md`, `~/.claude/rules/context-checkpoint.md`, `~/.claude/rules/tdd-phase.md`, and `~/.claude/rules/subagent-contract.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ task, artifact_inputs, ledger_path, stage, authority }`. Standalone callers may omit `artifact_inputs`, `ledger_path`, and `stage`; embedded callers supply `stage` and `authority: local_only`.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local test-strategy artifact. Append its outcome to an existing workflow ledger only in standalone mode; embedded mode returns the outcome for `my-workflow` to record. Never write production code or tests, publish, send, push, create/update remote content, deploy, or make any other outward action. Return such intent as `external_action_requested`.

## Output

Return the protocol's compact decision/artifact envelope. In embedded mode, record genuine testing trade-offs as recommended provisional decisions; do not interrupt the pipeline or claim user approval.
