---
model: opus
name: quality-audit
description: Deep audit of test quality, coverage fidelity, flakiness risk, assertions, mocks, and whether tests actually catch intended bugs.
---

# Quality Audit

Evaluate whether the test suite meaningfully protects the behavior under review.

## Load Rules

Read `~/.claude/rules/review-finding-format.md` and `~/.claude/rules/pr-mode-readonly.md` when applicable. Use `~/.agents/rules/` under Codex. For full checklist, read `references/protocol-index.md`.

## Flow

1. Identify behavior under test from PR, plan, spec, or diff.
2. Read changed tests and relevant production code.
3. Check assertion fidelity, negative paths, boundaries, fixtures, mocks/stubs, async behavior, and regression coverage.
4. Look for vacuous tests, over-mocking, brittle timing, hidden coupling, and missing integration coverage.
5. Calibrate findings by whether a realistic bug would escape.

## Output

Return blocking and non-blocking findings with file:line evidence, why the current test would miss the bug, and the exact stronger test to add.

