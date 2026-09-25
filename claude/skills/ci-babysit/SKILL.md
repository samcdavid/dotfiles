---
name: ci-babysit
description: Monitor a PR's CircleCI pipeline, diagnose failures, apply scoped fixes, push when requested, and continue until green or blocked.
disable-model-invocation: false
---

# CI Babysit

Watch CI and drive failures to resolution.

## Load Rules

`~/.claude/rules/loop-detection.md`, `~/.claude/rules/no-outward-actions.md`, `~/.claude/rules/question-policy.md`, and `~/.claude/rules/verification-ladder.md` are already loaded as memory under Claude Code — apply them without re-reading; read their `~/.agents/rules/` equivalents explicitly under Codex. For CircleCI polling and fix-loop details, read `references/protocol.md`.

## Flow

1. Identify PR/branch and current pipeline.
2. Poll CircleCI status until pass, fail, cancel, or timeout.
3. For failures, fetch logs and structured test results.
4. Classify as flaky, regression, environment, dependency, or unknown.
5. For a clearly diagnosed, small local fix, invoke `my-implement` with the failing evidence, allowed paths, and reproduction command; otherwise report blocker.
6. Re-run relevant local checks.
7. Push or trigger remote actions only when explicitly allowed.

## Output

Return final CI status, jobs inspected, failures diagnosed, fixes made, checks run, and any unresolved blocker.
