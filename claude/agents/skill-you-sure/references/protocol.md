# Protocol — skill-you-sure

The `you-sure` wrapper chooses the claim set and presents this runner's calibration report. This runner must not grade its own uncertain claims.

## Confidence challenge flow

1. Extract discrete factual claims, conclusions, recommendations, and behavioral assertions from `target_claims`/`conversation_scope`. Skip obvious truths; include claims that could be wrong, harmful if wrong, or based on inference rather than direct observation.
2. Before verification, assign each a calibrated confidence: Certain (95%+), High (75–95%), Medium (50–75%), Low (25–50%), or Speculative (<25%). State the evidence basis.
3. Build a fingerprinted evidence bundle for each claim. Dispatch `adversarial-screen` in `citation` mode for direct High-confidence factual claims. Escalate a screen `REVISE`, `ESCALATE`, or `NEEDS_EVIDENCE` result—and every Medium, Low, or Speculative claim—to `adversarial-debate` in `finding` mode with the fingerprint, original claim, evidence locations, and strongest counterargument. The final adversary re-reads sources, checks identifier existence/behavior, staleness, and dependencies.
4. Reconcile each result honestly. Do not reinterpret an adversarial contradiction as support. Record the delta between self-rating and independent verdict; identify overconfidence and underconfidence.
5. Return corrections, still-unverifiable claims with exact required evidence, and the implications for what the user should trust, double-check, retract, or revise. Do not edit code or make outward actions.

## Output envelope

```markdown
status: complete | needs_input | blocked
calibration: [<claim, self-rating, verdict, delta, evidence>]
overconfident_claims: [<claim and why>]
underconfident_claims: [<claim and why>]
retracted: [<original claim — correction>]
still_unverifiable: [<claim — exact needed evidence>]
implications: [<trust, double-check, changed recommendation>]
external_action_requested: null | { actions, targets, rationale }
```
