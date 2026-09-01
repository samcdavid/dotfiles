---
model: sonnet
effort: high
name: you-sure
runner: skill-you-sure
description: Adversarial confidence challenge. Forces calibrated confidence ratings on claims from the conversation, then dispatches an independent agent to verify them. Use when something feels off, before acting on recommendations, or to keep Claude honest.
disable-model-invocation: false
disallowed-tools: Edit, Write, NotebookEdit
---

# You Sure?

Use `skill-you-sure` for the substantive independent confidence challenge. This wrapper defines the claim set and preserves the user-facing correction boundary; the runner owns calibration and adversarial verification.

## Dispatch

Normalize the request into `{ target_claims, conversation_scope, authority: local_only }` and dispatch it to `skill-you-sure`.

- With a specific quoted claim or topic, restrict the challenge to that target; otherwise challenge the most recent substantive response.
- The runner screens direct High-confidence factual claims with
  `adversarial-screen`; it escalates unresolved screen results and every
  Medium/Low/Speculative claim to `adversarial-debate`, recording the
  fingerprinted evidence bundle. Return any request for access or an external
  action instead of performing it.

## Present

Return the confidence-calibration table, over/underconfidence, retractions, still-unverifiable claims, actionable implications, and the compact evidence envelope. Do not include raw adversarial transcripts.
