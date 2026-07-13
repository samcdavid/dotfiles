---
model: opus
name: security-audit
description: Deep security audit for code changes or areas: auth/authz, data exposure, injection, secrets, dependency risk, and OWASP-style issues.
---

# Security Audit

Review for concrete exploitable or data-exposure risk.

## Load Rules

Read `~/.claude/rules/review-finding-format.md`, `~/.claude/rules/pr-mode-readonly.md`, and `~/.claude/rules/model-escalation.md` when available. Use `~/.agents/rules/` under Codex. For full checklist, read `references/protocol-index.md`.

## Flow

1. Determine scope from PR, diff, path, ticket, or user prompt.
2. Trace trust boundaries, auth/authz checks, input validation, data access, external calls, file upload/download paths, token handling, and secrets.
3. Check dependency or config changes for exposure.
4. Verify claims against code and framework behavior.
5. Classify by exploitability and impact.

## Output

Findings must include affected asset/data, attacker or misuse path, evidence, impact, and concrete mitigation.

