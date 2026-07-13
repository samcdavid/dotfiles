## Step 2 — Investigate Every Comment

Apply `~/.claude/rules/pr-cost-control.md`: work from filtered comment payloads, retrieve compressed output only by relevant query, batch file/test reads for one investigation pass, and verify edits with `git diff` or targeted checks instead of immediate re-reads.

**Every comment requires investigation before deciding how to respond.** Do not accept feedback blindly, and do not reject it without evidence. The standard of rigor is the same regardless of whether you end up agreeing or disagreeing.

Before starting, read `references/pushback-patterns.md`. It documents the shapes that well-calibrated pushback takes across senior Elixir-ecosystem developers. The "When to push back vs. when to accept" decision table near the end is the load-bearing piece — use it to map each comment's category to a response pattern.

For each pending comment:

1. **Reproduce the concern.** Read the referenced code. Does the reviewer's claim hold? If they say there's a bug, can you construct the failing case? If they suggest an alternative, does it actually work in context? If they flag a missing edge case, trace the code path — does the value they're worried about actually reach this point?
2. **Check the codebase.** If the reviewer suggests using an existing utility or pattern, verify it exists and does what they think it does. If they suggest a refactor, check whether it would break callers. If they flag a naming issue, check how the term is used elsewhere in the domain.
3. **Check the docs.** If the feedback involves a library API, framework behavior, or Oban/Ecto pattern, verify against actual documentation — not memory.
4. **Form a judgment with evidence.** You now know whether the reviewer is right, partially right, or mistaken. Classify accordingly — and consult `references/pushback-patterns.md` to pick the response shape that fits (e.g. Pattern 3 "evidence-backed pushback" for falsifiable bot claims, Pattern 1 "out-of-scope defer" for adjacent cleanup, Pattern 4 "acknowledge-and-fix" for clear bugs).

### Deduplication Requests

When a reviewer requests deduplication (DRY refactors, "extract this repeated pattern", "this is duplicated"), count the actual occurrences before accepting:

- **≤3 occurrences** → push back. Three instances of a pattern is not a strong enough signal to justify extraction at review time. Classify as **Disagree / Push Back** (see below).
- **>3 occurrences** → treat as a Confirmed Fix or Partially Correct item and proceed.

The push-back response must:
1. Acknowledge the reviewer's DRY instinct.
2. State the actual count: "I count N occurrences of this pattern."
3. Explain the threshold: "At N occurrences, introducing an abstraction adds indirection without enough payoff — the bar for extraction is more than 3."
4. Offer to revisit: "Happy to extract it if this pattern spreads further."

### Classification

After investigation, classify each comment:

#### Confirmed Fix

Investigation confirms the reviewer is correct. You have evidence (the code path, the failing case, the doc reference) that the change should be made.

#### Question Requiring Response

The reviewer asked about intent or design. No code change needed — but your response should demonstrate you investigated, not just defended.

#### Valid Deferral

Investigation confirms the feedback is correct, but the fix is out of scope — too large, requires coordination, or is a separate concern. You have a concrete reason for deferring AND a follow-up plan.

#### Disagree / Push Back

Investigation shows the reviewer's suggestion would be incorrect, break something, or conflict with a constraint. You have concrete evidence (linter rule, failing test, contract, doc reference).

#### Partially Correct

The reviewer identified a real concern but their specific suggestion isn't quite right. You'll fix the underlying issue a different way. Your response should acknowledge the concern and explain your alternative approach.

#### Already Addressed

The feedback was already fixed in a subsequent commit but the reviewer wasn't notified.

### Adversarial Challenge

Before presenting your triage, spawn the **adversarial-debate** agent to challenge your classifications.

Format each classification as a finding and pass it to the agent along with:

- The original reviewer comment (full text)
- Your investigation evidence
- Your classification and planned action
- The referenced code (file paths)

The agent will challenge:

- **Confirmed Fixes**: steel-man the current code — is acceptance actually justified?
- **Push Backs**: steel-man the reviewer — could they be right and you wrong?
- **Deferrals**: is this genuinely out of scope, or avoiding a hard fix? (Under 20 lines = not a deferral)
- **Partially Correct**: does your alternative actually address the reviewer's concern, or sidestep it?
- **Contradictions**: accepting a pattern in one fix but pushing back on the same pattern elsewhere?

Apply the agent's verdicts — reclassify items as needed before presenting.

### Importance Filter — `/this-important`

After the adversarial challenge, run the post-investigation classifications through `/this-important` to filter for importance. Investigation tells you whether a reviewer's concern is valid; importance filtering tells you whether it's worth a fix-and-commit cycle right now versus a deferral or a brief reply.

Invoke `/this-important strict` by default. Use `moderate` if I've signaled this is a high-polish PR (release branch, external-facing API, customer-reported regression). Use `loose` only if I explicitly ask.

Pass every classified comment as a finding. Apply the returned verdicts:

- **KEEP** → stays as Confirmed Fix / Partially Correct (proceed to plan in Act II)
- **DOWNGRADE** → move from Confirmed Fix to Question Requiring Response (reply with investigation findings, no code change)
- **DEFER** → move to Valid Deferral (must have a follow-up plan)
- **DROP** → only valid for items already in the Question or Push Back classifications where investigation showed no real concern; never drop a verified reviewer-flagged bug, security issue, or data-loss risk

Hard rule: never downgrade or drop a finding from a reviewer whose review was marked as blocking ("Request changes") without surfacing the change to the user explicitly. The reviewer's gate stands until they remove it; importance filtering is for your own action prioritization, not for overriding their blocking review.

Present the triage to the user **with your investigation findings**:

```
