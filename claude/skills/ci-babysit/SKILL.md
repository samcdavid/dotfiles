---
model: sonnet
name: ci-babysit
description: Monitor a PR's CircleCI pipeline, diagnose failures, apply scoped fixes, push when requested, and continue until green or blocked.
disable-model-invocation: false
---

# CI Babysit

Watch CI and drive failures to resolution.

## Load Rules

Read `~/.claude/rules/loop-detection.md`, `~/.claude/rules/no-outward-actions.md`, and `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For CircleCI polling and fix-loop details, read `references/protocol.md`.

## Flow

1. Identify PR/branch and current pipeline.
2. Poll CircleCI status until pass, fail, cancel, or timeout.
3. For failures, fetch logs and structured test results.
4. Classify as flaky, regression, environment, dependency, or unknown.
5. Apply small local fixes when clearly in scope; otherwise report blocker.
6. Re-run relevant local checks.
7. Push or trigger remote actions only when explicitly allowed.

## Output

Return final CI status, jobs inspected, failures diagnosed, fixes made, checks run, and any unresolved blocker.

