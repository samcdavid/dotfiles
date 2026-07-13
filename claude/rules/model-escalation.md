# Model Escalation

Use cheaper/default models for routing, search, formatting, orchestration, and simple implementation.

Escalate only high-judgment work:

- Security, architecture, and performance review.
- Adversarial verification of findings.
- Ambiguous product scope decisions.
- Final synthesis only after noisy parallel investigation or conflicting reviewer outputs.

Claude agents may express escalation with `model: opus`. Codex generated agents inherit elevated reasoning or `CODEX_CRITICAL_MODEL` from `scripts/sync-codex-agents`.
