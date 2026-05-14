---
name: this-important
description: Challenges the importance of findings from a previous response (code reviews, audits, plans, reviewer comments). Filters noise by forcing each finding to clear an explicit importance bar so only items worth raising or addressing survive. Use after a review/audit, before acting on a list of recommendations, or any time a previous response produced more findings than feel worth the cost.
---

# This Important?

For each finding from a previous response, justify why it's important enough to act on. Drop everything that does not clear the bar.

The premise: noise has a cost. A finding that gets raised must be defendable; a finding that gets addressed must be worth the change. The default verdict for borderline items is **DROP** — the burden of proof sits on the finding, not on the filter.

## Step 0 — Set the Bar

Parse `$ARGUMENTS` for a bar level. Default is **strict**.

| Bar | What survives | What drops |
|-----|---------------|------------|
| **strict** (default) | Items that will cause a bug, lose data, create a vulnerability, break a contract, or compound if left in place. | Style, preference, nits, "could be cleaner", speculative perf, anything reversible cheaply later. |
| **moderate** | Above, plus clarity/maintainability items that materially help future readers or prevent foot-guns. | Pure style, formatting, naming preference, hypothetical perf without evidence. |
| **loose** | Above, plus anything that improves the code if cheap to apply. | Bikeshedding, redundant findings, items already covered by tooling. |

If `$ARGUMENTS` contains `strict`, `moderate`, or `loose`, use it. Otherwise default to **strict**.

State the bar back to the user in one line before proceeding.

## Step 1 — Identify Target Findings

Determine what to challenge:
- If `$ARGUMENTS` contains structured findings (passed in by another skill), use those.
- If `$ARGUMENTS` names a specific area or topic, focus on findings in that area from the recent conversation.
- Otherwise → use **every discrete finding from the most recent substantive response** (blocking issues, suggestions, questions, recommended fixes, audit items, plan items).

For each finding, extract:
- Its current label / severity (e.g. blocking, non-blocking, nit, suggestion)
- The specific concern — what is being claimed as wrong, missing, or worth changing
- The proposed action — what would be done to address it
- The evidence cited — file:line, doc reference, command output, or "(none)" if absent

If a finding has no evidence cited, mark it for skeptical treatment — speculative findings rarely clear the bar.

## Step 2 — Score Against the Importance Bar

For each finding, evaluate against four lenses. Write the score down for each — do not collapse to a gut verdict.

### Impact — what's at stake?

- **Production**: bug, data loss, security vulnerability, outage risk, contract break
- **User**: visible to a user, blocks a workflow, degrades UX measurably
- **System**: degrades performance under realistic load, increases ongoing cost, accumulates debt that compounds
- **Team**: misleads future readers in a way that will cause real bugs, sets a precedent that will be copied harmfully
- **None**: subjective preference, style, taste, "could be cleaner"

### Cost-of-Inaction — what happens if we skip it?

- **Unrecoverable**: data loss, security breach, downstream breakage that can't be rolled back
- **Hard to fix later**: locked into a structure (public API, schema, contract, migration) that will be expensive to change
- **Easy to fix later**: trivially reversible, isolated, no compounding cost
- **Self-correcting**: will surface naturally (tests catch it, monitoring flags it, next reader fixes it)

### Confidence in the Finding Itself

- **Verified**: grounded in actual code, docs, or evidence cited in the finding
- **Plausible**: pattern match, convention, not directly traced
- **Speculative**: based on general knowledge or hypothesis; no project-specific evidence

### Cost-of-Action — what does fixing cost?

- **Cheap**: minutes, isolated edit
- **Moderate**: hours, touches multiple files, requires re-testing
- **Expensive**: days, coordination, migration, or risk of regression

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

## Step 4 — Cross-Check for Calibration

Before reporting, scan the verdicts for consistency:

- Is any KEEP item weaker than a DROP item? If yes, reclassify.
- Are similar findings classified differently for no principled reason? If yes, align them.
- Did the same concern appear in multiple findings? Merge duplicates.
- For each KEEP, can you state "If we ship without this, X will happen" with a concrete X? If not, downgrade or drop.

## Step 5 — Report

```markdown
## Importance Filter ([bar level])

### Kept ([N])
| # | Finding | Severity | Why It Matters |
|---|---------|----------|----------------|
| 1 | [summary, file:line] | Blocking | [concrete consequence of not acting] |

### Downgraded ([N])
| # | Finding | Was | Now | Reason |
|---|---------|-----|-----|--------|
| 1 | [summary] | Blocking | Non-blocking | [why lower severity is right] |

### Deferred ([N])
| # | Finding | Reason | Follow-up |
|---|---------|--------|-----------|
| 1 | [summary] | High cost-of-action, low cost-of-inaction | [ticket / next-PR / specific plan] |

### Dropped ([N])
| # | Finding | Why Dropped |
|---|---------|-------------|
| 1 | [summary] | [specific reason: speculative, pure style, duplicate, low impact + easy to fix later, etc.] |

### Bar Calibration Notes
[1–2 sentences: was the bar applied consistently? Any close calls worth surfacing to the user?]
```

## Step 6 — Hand Back

When invoked by another skill, return the filtered result as the new working set of findings. The calling skill should use only the **Kept** and **Downgraded** items for downstream action (raising, fixing, posting). **Deferred** items become follow-ups, not actions. **Dropped** items are gone — do not silently resurrect them.

When invoked directly by the user, end with a one-line summary:
> "Filtered N findings → K kept, D downgraded, F deferred, X dropped. Proceed with the K + D items?"

## Guidelines

- The honest test for every finding: **"If we shipped without addressing this, what would actually go wrong?"** If the answer is "nothing visible," drop it.
- Don't downgrade out of politeness or upgrade out of thoroughness. Calibration over comfort.
- Speculative findings need verification, not benefit of the doubt. If you can't verify it in this step, drop it.
- This skill is allowed to disagree with the previous response's severity labels. That's its job.
- Never drop a security or data-loss finding without explicit verification that the concern doesn't apply. Better to keep a false positive in this category than miss a real one.
