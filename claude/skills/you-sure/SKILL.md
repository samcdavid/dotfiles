---
name: you-sure
description: Adversarial confidence challenge. Forces calibrated confidence ratings on claims from the conversation, then dispatches an independent agent to verify them. Use when something feels off, before acting on recommendations, or to keep Claude honest.
---

# You Sure?

Challenge the confidence behind claims made in this conversation. An independent agent verifies — the one who made the claims doesn't get to grade their own homework.

## Step 1 — Identify Target Claims

Determine what to challenge:
- If `$ARGUMENTS` contains a quoted string or specific topic → challenge that specific claim or area
- If `$ARGUMENTS` is empty → challenge the **most recent substantive response**

Extract every discrete factual claim, conclusion, recommendation, or behavioral assertion from the target. Skip obvious truths and focus on claims that:
- Could plausibly be wrong
- Would cause harm if wrong
- Were stated with more confidence than the evidence warrants
- Involve memory, inference, or extrapolation rather than direct observation

## Step 2 — Self-Report Confidence (Before Verification)

For each extracted claim, assign a confidence level **before** any verification happens. Be honest — this is calibration, not performance.

| Level | Meaning | Typical Basis |
|-------|---------|---------------|
| **Certain (95%+)** | Would bet on it. Based on direct evidence read in this session. | Read the file, ran the command, saw the output |
| **High (75-95%)** | Very likely correct but some gap exists. | Read related code but not this exact path; strong pattern match |
| **Medium (50-75%)** | Reasonable belief but meaningful uncertainty. | Inferred from conventions, documentation, or partial evidence |
| **Low (25-50%)** | More guess than knowledge. | Extrapolated from general knowledge, no project-specific evidence |
| **Speculative (<25%)** | Essentially a hypothesis. | No direct evidence; stated because it seemed plausible |

## Step 3 — Independent Verification

Launch an `adversarial-debate` agent to independently verify each claim rated below **Certain**. The agent must:

1. **Re-read source material** — Don't trust summaries. Go back to the actual files, commands, or outputs.
2. **Grep for quoted identifiers** — If a function name, variable, config key, or path was mentioned, confirm it exists and behaves as described.
3. **Steel-man the opposite** — For each claim, construct the strongest argument that it's wrong. What would have to be true for the claim to fail?
4. **Check for staleness** — If evidence was read earlier in the conversation, has anything changed since? Could the context have shifted?
5. **Look for silent dependencies** — Does the claim depend on assumptions that weren't stated? Are there conditions under which it breaks?

The agent should return a verdict for each claim:
- **Confirmed** — independent evidence supports it
- **Weakened** — partially true but overstated or missing nuance
- **Contradicted** — evidence points the other way
- **Unverifiable** — cannot be confirmed or denied with available tools

## Step 4 — Calibration Report

Present the results as a calibration table:

```
## Confidence Calibration

| # | Claim | Self-Rated | Verified | Delta | Evidence |
|---|-------|-----------|----------|-------|----------|
| 1 | [claim summary] | High (85%) | Confirmed | — | [file:line or command] |
| 2 | [claim summary] | High (80%) | Weakened | ↓ | [what was wrong/missing] |
| 3 | [claim summary] | Medium (60%) | Contradicted | ↓↓ | [actual finding] |

### Overconfident Claims
[List any claims where self-rating was significantly higher than verification warranted]

### Underconfident Claims  
[List any claims where self-rating was lower than the evidence supports — calibration goes both ways]

### Retracted
[Any claims that should be withdrawn entirely, with corrections]

### Still Unverifiable
[Claims that couldn't be checked — state what would be needed]
```

## Step 5 — So What?

End with actionable implications:
- What should the user **trust** from this conversation?
- What should the user **double-check** themselves?
- What should be **retracted or corrected** before proceeding?
- Has this changed the recommendation or plan that was being discussed?

Do not soften findings to preserve ego. The point is accuracy and calibration, not comfort.
