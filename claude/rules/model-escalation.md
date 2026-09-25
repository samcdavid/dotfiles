# Model Escalation

Skills and agents run on the session model by default: agents set `model: inherit`, skills omit `model:`, and Codex agents omit `codex-model:`. Pin a model only to escalate high-judgment work above the session.

Escalate only high-judgment work:

- Security, architecture, and performance review.
- Adversarial verification of findings.
- Ambiguous product scope decisions.
- Final synthesis only after noisy parallel investigation or conflicting reviewer outputs.

Use `adversarial-screen` (session model) first for a direct citation, bounded
low-risk finding, or reversible decision with a current evidence-bundle
fingerprint. Escalate its result to `adversarial-debate` (Opus / `gpt-6-sol`) only for material
risk, contradictory evidence, nontrivial causality or external semantics, an
irreversible decision, or an unresolved screen result. `my-review` may dispatch
the deep tier directly for its high-tier findings and eligible verdict challenge.

## Expressing Escalation

Prefer `effort:` (`low`, `medium`, `high`, `xhigh`, `max`) over a model pin. Effort scales reasoning depth on whatever model is current, so it does not need revisiting as models change, and `scripts/sync-codex-agents` maps it straight to Codex `model_reasoning_effort`.

Use `model:` only to escalate — `model: opus` for the deep tier. Do not pin a cheaper model (`sonnet`, `haiku`) or a cheaper Codex model: it permanently caps that skill below the session model, and the session model is the user's chosen cost/quality tradeoff.

Both fields can coexist: `model:` escalates the tier, `effort:` chooses how hard it thinks.

Final synthesis over conflicting subagent output is high-judgment work and should not run below the tier of the agents feeding it.

Codex generated agents inherit elevated reasoning from `effort:`, or from `model: opus` plus `CODEX_CRITICAL_MODEL` as the legacy fallback. Codex has no equivalent of `disallowedTools`, so read-only guarantees for generated Codex agents remain prose-only.
