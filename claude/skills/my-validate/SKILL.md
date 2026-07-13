---
model: sonnet
name: my-validate
description: Validate work against a plan or current session. Runs mechanical checks, verifies claims against code, repairs local failures when safe, and reports residual risk.
---

# Validate

Verify that implemented work matches the plan, claims, and expected behavior. Attempt safe local repair before escalating.

## Load Rules

Read:

- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/no-outward-actions.md`

Use `~/.agents/rules/` when running through Codex. For observability validation, session-mode claim audits, or ambiguous failures, read `references/protocol-index.md`.

## Modes

- **Plan Mode:** `$ARGUMENTS` contains a plan path.
- **Session Mode:** validate current conversation claims and working-tree changes.

Ask only if mode cannot be inferred.

## Flow

1. Inventory expected behavior, claims, files changed, commands already run, and artifact paths.
2. Read the plan or session evidence.
3. Run mechanical checks first: targeted tests, full relevant suite, lint/typecheck/format, grep checks.
4. Cross-check code against requirements and acceptance criteria.
5. If a local failure has an obvious scoped fix, repair and re-run checks.
6. Apply loop detection for repeated failures.
7. Save or append validation report when a workflow ledger exists.

## Output

Return checks run, pass/fail results, repairs made, requirement coverage, residual risks, and any blocker that needs user decision or deeper investigation.

