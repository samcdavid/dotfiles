---
model: sonnet
name: quick-plan
description: Create a small executable quick-plan for simple changes, with TDD or direct-edit phases and mechanical success criteria.
---

# Quick Plan

Create a compact plan for a simple, well-understood change.

## Load Rules

Read `~/.claude/rules/tdd-phase.md` and `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For full planning rules, read `references/protocol-index.md`.

## Flow

1. Resolve task from prompt, ticket, or current context.
2. Confirm it fits quick-plan scope.
3. Inspect relevant files and tests.
4. Create phases:
   - TDD for behavioral changes.
   - Direct edit for structural/non-behavioral changes.
5. Include allowed paths, success criteria, verification commands, and constraints.
6. Save under the quick-plan location used by `quick-implement`.

## Output

Return plan path, phases, checks, and tripwire conditions that would require full planning.

