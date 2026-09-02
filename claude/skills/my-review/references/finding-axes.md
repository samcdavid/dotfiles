# Finding Axes — severity, risk, confidence

Every actionable finding carries three independent axes. The whole-diff worker assigns them; an eligible verifier may revise them only with cited evidence.

| Axis | Question | Values |
|---|---|---|
| Severity | If true, how bad is the impact? | `Critical` · `Non-blocking` · `Question` · `Nit` |
| Risk | How likely and wide is the failure, if true? | `High` · `Medium` · `Low` |
| Confidence | How certain is the factual claim? | integer `0`–`100` |

Severity is conditional impact. Risk is likelihood times blast radius assuming the claim is true. Confidence is a calibrated factual-belief estimate; do not collapse these axes.

## Confidence calibration

- `80`–`100`: the defect is directly visible after checking the relevant code and causal prerequisites.
- `50`–`79`: the code suggests the claim, but one prerequisite remains unchecked.
- `0`–`49`: the claim is substantially inferred or depends on unavailable facts.

When reachability, a caller, schema, configuration, dependency behavior, or pinned-version semantic is not directly checked, confidence **must be at most 79**. Name the missing fact; never round it up merely to obtain deeper review.

## Verification routing

The default review is already a complete Sonnet whole-diff review. Do not add a verifier merely because it emitted a finding.

```
Opus: finding-verifier-high
  if (severity == Critical OR risk == High) AND confidence >= 80

Targeted Sonnet: finding-verifier-low
  only if verification_need == needs_confirmation AND all of:
  - a named unresolved fact
  - an exact verification query
  - routing_consequence == code verdict OR Opus eligibility
```

All other actionable findings remain **not independently verified** and are verdict-neutral. Ask an author-only question when only the author can supply the missing fact. The targeted Sonnet verifier may revise axes with evidence; send its result to Opus only when the revised finding satisfies the exact Opus predicate. Never add a second verifier otherwise.
