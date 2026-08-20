---
model: sonnet
effort: high
name: prove-it
runner: skill-prove-it
description: Lightweight fact-check of the current conversation. Separates verified facts from unverified assumptions, cites evidence for each, and flags trust debt. Use when findings feel uncertain or before acting on research.
disable-model-invocation: false
---

# Prove It

Use `skill-prove-it` for the substantive conversation fact-check. This wrapper defines the target claims, preserves the user-facing correction boundary, and presents the runner's compact evidence ledger.

## Dispatch

Normalize the request into `{ target_claims, conversation_scope, authority: local_only }` and dispatch it to `skill-prove-it`.

- With a specific quoted claim or topic, restrict the audit to that target; otherwise audit the most recent substantive response.
- The runner independently verifies available evidence, clearly retracts unsupported claims, and returns any request for access or an external action instead of performing it.

## Present

Return verified facts, formerly assumed facts now verified, retractions, still-unverified claims with exact next checks, and the compact evidence envelope. Do not defend earlier claims or include raw verifier transcripts.
