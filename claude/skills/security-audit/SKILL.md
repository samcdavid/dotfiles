---
model: opus
effort: high
name: security-audit
runner: skill-security-audit
description: "Deep security audit for code changes or areas: auth/authz, data exposure, injection, secrets, dependency risk, and OWASP-style issues."
disallowed-tools: Edit, Write, NotebookEdit
---

# Security Audit

Use `skill-security-audit` for the substantive dedicated security audit. This wrapper resolves the scope and review mode, keeps the user-facing boundary, and presents the runner's evidence-backed audit envelope.

## Dispatch

Normalize the request into `{ target, mode, threat_context, artifact_inputs, authority: local_only }` and dispatch it to `skill-security-audit`.

- Derive `mode` as PR, diff/range, local path, or feature area. Ask for a target only when none can be inferred.
- Preserve supplied asset, attacker, data-classification, and deployment context without asserting facts the evidence does not support.
- The runner uses the retained shared checklist at `references/protocol.md`, delegates substantive assessment to `security-reviewer`, and returns any external-action intent rather than performing it.

## Present

Return material findings with affected asset/data, attacker or misuse path, evidence, impact, concrete mitigation, dismissed concerns, residual unknowns, and the compact audit envelope. Do not include raw subagent transcripts.
