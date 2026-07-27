---
model: opus
effort: xhigh
name: requirements-audit
description: Audit a PR, ticket, spec, or local change against stated requirements and acceptance criteria.
disallowed-tools: Edit, Write, NotebookEdit
---

# Requirements Audit

Trace requirements to implementation and tests. Focus on missing, partial, excessive, or contradictory behavior.

## Load Rules

Read `~/.claude/rules/question-policy.md`, `~/.claude/rules/review-finding-format.md`, and `~/.claude/rules/pr-mode-readonly.md` when applicable. Use `~/.agents/rules/` under Codex. For full audit procedure, read `references/protocol.md`.

## Flow

1. Identify source of requirements: Linear, PR body, spec, plan, or user-provided text.
2. Build an acceptance-criteria checklist.
3. Read relevant implementation, tests, and diffs.
4. Classify each criterion as Covered, Partial, Missing, Excess, or Unclear.
5. Verify tests would catch important regressions.
6. Run adversarial challenge for non-obvious findings.

## Output

Findings first, with requirement reference, implementation evidence, test evidence, severity, and concrete fix.

