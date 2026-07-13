## Step 3 — Verdict

Assign one verdict per finding:

| Verdict | When |
|---------|------|
| **KEEP** | Impact is Production/User/System OR cost-of-inaction is Unrecoverable/Hard. Confidence is Verified or Plausible. Worth raising/addressing now. |
| **DOWNGRADE** | Real concern but lower severity than originally labeled. Move blocking → non-blocking, or finding → question. |
| **DEFER** | Real and verified, but cost-of-action is high and cost-of-inaction is low/recoverable. Capture as follow-up, don't act now. |
| **DROP** | Low impact AND cheap to fix later, OR speculative without verification, OR pure preference. Don't raise/address. |

### Bar rules

Apply the chosen bar level as a tie-breaker on borderline cases:

- **strict** — Anything below "would cause a bug, lose data, break a contract, or compound" drops. Aggressive about dropping style, preference, speculative perf, and "could be cleaner" items.
- **moderate** — Keep clarity/maintainability items that materially help future readers. Drop pure style and unverified perf.
- **loose** — Keep cheap improvements. Drop only redundant findings, bikeshedding, and items already covered by tooling (lint, formatter, type checker).

### Hard rules (any bar)

- Speculative findings (Confidence = Speculative) → DROP unless verified during this step.
- Style/formatting/naming preferences with no functional impact → DROP at strict, DROP at moderate, KEEP only if explicit team convention.
- Findings already raised in existing review threads → DROP (duplicate noise).
- Findings the original response itself labeled as nits or questions with no action → DROP unless they cross the bar on review.
- A KEEP item must be one you would defend if challenged — if you can't articulate the bug/loss/break in one sentence, downgrade it.
