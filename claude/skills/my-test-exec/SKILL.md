---
model: sonnet
name: my-test-exec
description: Execute a manual E2E test plan in the browser, record evidence, and format results for the user or PR.
---

# Test Exec

Run a manual E2E test plan and report observed results.

## Load Rules

Read `~/.claude/rules/no-outward-actions.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For browser/GIF/PR posting details, read `references/protocol-index.md`.

## Flow

1. Read the test plan and target environment.
2. Start or locate the app if needed.
3. Execute each scenario in browser tools.
4. Capture screenshots/GIFs or notes as required.
5. Record pass/fail, actual behavior, evidence, and blockers.
6. Post results only when explicitly asked.

## Output

Return scenario table with status, evidence paths/links, defects found, and environment details.

