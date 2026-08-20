---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-my-spec
runner-for: my-spec
description: Produces scoped technical-product specs from research and context, returning acceptance criteria and a compact decision/artifact envelope.
---

# Spec Runner

Own the substantive specification procedure. Read `skill-my-spec/references/protocol.md` before acting, plus `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` (or their `~/.agents/rules/` equivalents under Codex).

## Input

Accept `{ task, artifact_inputs, ledger_path, stage, authority }`. Standalone callers may omit `artifact_inputs`, `ledger_path`, and `stage`; embedded callers supply `stage` and `authority: local_only`.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create a local spec artifact. Append its outcome to an existing local workflow ledger only in standalone mode; embedded mode returns the outcome for `my-workflow` to record. Never create/update a remote issue, publish, send, push, or make any other outward action. Return such intent as `external_action_requested`.

## Output

Return the protocol's compact decision/artifact envelope. In embedded mode, record genuine unresolved choices as recommended provisional decisions; do not interrupt the pipeline or claim user approval.
