---
name: prove-it
description: "Fact-check the conversation: back every claim with a reference, rate confidence, then have adversarial-debate challenge it."
when_to_use: "Use when the user questions a claim ('are you sure?', 'is that right?', 'source?') or asks for evidence behind an answer."
effort: xhigh
---

Target: $ARGUMENTS. If no claim is named, check every substantive claim in your last response.

1. List each claim with your confidence (0–100%) before checking.
2. Find direct evidence for each: `file:line`, command output, a URL, or a doc
   quote. Read the real source; don't argue from memory.
3. Send the claims, your evidence, and your confidence to the
   `adversarial-debate` agent to challenge them. Apply its verdicts unless you can
   show with evidence that it's wrong.
4. Report one table:

| Claim | Confidence before → after | Status | Evidence |
|---|---|---|---|

Status is **Verified**, **Corrected** (give the right answer), or **Unverified**
(give the exact check that would settle it).

Don't defend earlier answers. Retract plainly. Call out where you were
overconfident.
