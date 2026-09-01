---
model: sonnet
name: update-deps
description: Update outdated dependencies across supported package managers, handling safe updates first and flagging breaking changes.
when_to_use: "Use when the user asks to update, upgrade, or bump dependencies, or to deal with outdated packages."
---

# Update Dependencies

Update dependencies while preserving behavior.

## Load Rules

Read `~/.claude/rules/no-outward-actions.md`, `~/.claude/rules/loop-detection.md`, and `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For manager-specific details, read `references/protocol.md`.
Use `verification-ladder.md` from the same rules directory for update checks.

## Flow

1. Detect package manager(s) and lockfiles.
2. Inspect outdated dependencies and constraints.
3. Prefer safe/minor/patch updates before breaking changes.
4. Delegate each approved, bounded update batch to `my-implement`, including manifest/lockfile paths and native package-manager commands.
5. Read changelogs or release notes for major/security-sensitive updates.
6. Run install, tests, lint/typecheck, and dependency audit checks.
7. Stop for breaking migration decisions.

## Output

Return packages changed, versions before/after, commands run, failures fixed, breaking changes deferred, and remaining risk.
