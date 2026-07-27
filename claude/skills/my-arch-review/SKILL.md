---
model: opus
effort: xhigh
name: my-arch-review
description: Architecture review of a PR, document, or code area for boundaries, coupling, cohesion, dependency direction, and maintainability.
disallowed-tools: Edit, Write, NotebookEdit
---

# Architecture Review

Evaluate whether the design fits existing system boundaries and creates maintainable precedent.

## Load Rules

Read `~/.claude/rules/review-finding-format.md`, `~/.claude/rules/question-policy.md`, and `~/.claude/rules/model-escalation.md` when available. Use `~/.agents/rules/` under Codex. For full checklist, read `references/protocol.md`.

## Flow

1. Determine architecture surface from diff, PR, spec, plan, or path.
2. Read current patterns and neighboring implementations.
3. Check dependency direction, ownership boundaries, abstraction fit, coupling, cohesion, extension path, and migration/rollback story.
4. Distinguish deliberate tradeoffs from accidental complexity.
5. Produce only findings with meaningful future maintenance or correctness impact.

## Output

Return architectural risks, why they matter, evidence, and recommended design adjustment.

