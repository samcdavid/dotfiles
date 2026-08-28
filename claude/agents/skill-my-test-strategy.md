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

Accept `{ mode, task, artifact_inputs, ledger_path, stage, authority }`. `mode` is `standalone`, `embedded`, or `focused_advisory`. Advisory callers supply one testing question plus relevant requirement/decision IDs and evidence.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local test-strategy artifact outside advisory mode. In `focused_advisory`, remain read-only and return evidence plus a proposed Test Strategy patch; never update the ledger yourself. Never write production code or tests, publish, send, push, create/update remote content, or deploy.

## Output

Return the protocol's normal envelope, or in `focused_advisory` return the exact
question, evidence, proposed test contracts as `{ id, desired_outcome,
assertion }`, recommendation/trade-offs, confidence, and ledger patch. Do not
claim user approval.
