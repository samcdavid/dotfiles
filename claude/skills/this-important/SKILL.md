---
effort: xhigh
name: this-important
description: Filter previous findings through an importance bar so only issues worth raising or fixing survive.
disallowed-tools: Edit, Write, NotebookEdit
---

# This Important

Calibrate findings for real importance. Do not re-review from scratch.

## Load Rules

`~/.claude/rules/review-finding-format.md` is already loaded as memory under Claude Code — apply it without re-reading; read the `~/.agents/rules/` equivalent explicitly under Codex. For calibration examples, read `references/protocol.md`.

## Flow

1. Take the supplied findings as input.
2. For each, identify the concrete consequence if ignored.
3. Drop or downgrade speculative, stylistic, duplicate, low-reach, or preference-only items.
4. Keep issues with plausible correctness, data, security, UX, operational, maintainability, or test-fidelity impact.
5. Preserve blocking reviewer gates unless the user explicitly chooses otherwise.

## Output

Return KEEP / DOWNGRADE / DEFER / DROP per finding with one-sentence rationale and any revised severity.
