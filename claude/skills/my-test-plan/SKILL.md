---
name: my-test-plan
description: Produce a manual E2E test plan from a ticket, PR, or code change with scenarios, setup, expected outcomes, and risk coverage.
---

# Test Plan

Design manual test scenarios that validate the intended behavior and likely regressions.

## Load Rules

`~/.claude/rules/question-policy.md` is already loaded as memory under Claude Code — apply it without re-reading; read the `~/.agents/rules/` equivalent explicitly under Codex.

## Flow

1. Read ticket/spec/PR/code context.
2. Identify user workflows, acceptance criteria, risks, and affected roles.
3. Create focused scenarios with setup, steps, expected result, and coverage rationale.
4. Include negative, edge, permission, and regression cases where relevant.

## Output

Return executable manual test plan and any setup/data requirements.

