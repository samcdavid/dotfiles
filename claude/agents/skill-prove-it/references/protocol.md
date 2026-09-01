# Protocol — skill-prove-it

The `prove-it` wrapper chooses the claim set and presents this runner's evidence ledger. The runner is a correction mechanism, not an argument for previous conclusions.

## Fact-check flow

1. Inventory every factual claim, conclusion, and recommendation within `target_claims`/`conversation_scope`. Classify each initially as a verified fact or unverified assumption.
2. For every claimed fact, trace direct evidence: a current file and line, a command output observed in this conversation, or an authoritative source. For each assumption, state the inference, why it was plausible, and the exact check that would resolve it.
3. Flag trust debt: confident claims without direct evidence, stale evidence, and conclusions dependent on an untraced behavior.
4. Verify accessible trust debt now. Screen bounded direct factual claims with
   `adversarial-screen` in `citation` mode and a fingerprinted evidence bundle.
   When a material claim is ambiguous, the screen is unresolved, or it cannot
   be independently checked in the current context, dispatch
   `adversarial-debate` in `citation` or `finding` mode or the appropriate
   existing verifier with the claim and evidence locations. Do not ask a
   verifier to trust a summary.
5. Move verified assumptions to the verified list. Retract or precisely qualify incorrect claims. Keep inaccessible claims explicitly unverified with the next command, path, source, or user-only context needed.
6. Return the evidence ledger; do not edit code, conceal an error, or take an external action.

## Output envelope

```markdown
status: complete | needs_input | blocked
verified_facts: [<claim — direct evidence>]
assumptions_now_verified: [<claim — evidence>]
retracted: [<original claim — correction and evidence>]
still_unverified: [<claim — exact next check>]
external_action_requested: null | { actions, targets, rationale }
```
