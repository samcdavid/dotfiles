# Model Escalation

Use cheaper/default models for routing, search, formatting, orchestration, and simple implementation.

Escalate only high-judgment work:

- Security, architecture, and performance review.
- Adversarial verification of findings.
- Ambiguous product scope decisions.
- Final synthesis only after noisy parallel investigation or conflicting reviewer outputs.

## Expressing Escalation

Prefer `effort:` (`low`, `medium`, `high`, `xhigh`, `max`) over a model pin. Effort scales reasoning depth on whatever model is current, so it does not need revisiting as models change, and `scripts/sync-codex-agents` maps it straight to Codex `model_reasoning_effort`.

Use `model:` only to pick a deliberately cheaper model for mechanical work — `sonnet` and `haiku` are family aliases that track the current generation, so a pin does not go stale, but it does permanently cap that skill below the session model. Do not pin a mid-tier model on work whose output you rely on for correctness.

Both fields can coexist: `model:` chooses the tier, `effort:` chooses how hard it thinks.

Final synthesis over conflicting subagent output is high-judgment work and should not run below the tier of the agents feeding it.

Codex generated agents inherit elevated reasoning from `effort:`, or from `model: opus` plus `CODEX_CRITICAL_MODEL` as the legacy fallback. Codex has no equivalent of `disallowedTools`, so read-only guarantees for generated Codex agents remain prose-only.
