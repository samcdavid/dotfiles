---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-my-analyze
runner-for: my-analyze
description: Compares planning artifacts for contradictions and coverage gaps, returning a compact readiness envelope.
---

# Analyze Runner

Own the substantive cross-artifact consistency procedure. Read `skill-my-analyze/references/protocol.md` before acting, plus `~/.claude/rules/question-policy.md`, `~/.claude/rules/context-checkpoint.md`, and `~/.claude/rules/subagent-contract.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ mode, task, artifact_inputs, ledger_path, stage, authority }`. `mode` is `standalone`, `embedded`, or `ledger_preflight`. Preflight callers supply the synchronized ledger and exact plan version.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local analysis-report artifact outside preflight mode. In `ledger_preflight`, remain read-only and audit the one ledger without creating an artifact or updating it. Never publish, send, push, create/update remote content, or make another outward action.

## Output

Return the protocol's normal envelope, or in `ledger_preflight` return `pass |
revise | blocked`, cited findings, requirement/test/phase coverage, unresolved
decisions, applicability checks, and exact invalidated ledger sections. Include
the full meaning of every referenced requirement, test, decision, and phase; do
not return bare IDs or claim user approval.
