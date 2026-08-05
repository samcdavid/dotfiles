# Finding Finalization

Load this after lens reviewers return.

1. Merge duplicate findings across lenses.
2. Dedupe against existing PR comments and threads.
3. Classify severity using the shared review rule:
   - Critical: must-fix-before-merge; eligible for `REQUEST_CHANGES`.
   - Non-blocking: worth raising, but not merge-blocking.
   - Question: needs author context.
   - Nit: tiny cleanup only if useful.
4. Split into two tiers (see `references/protocol.md` Step 6):
   - **Tier 1** — every Critical finding, plus every Security/cross-service-contract finding asserting a definite defect regardless of its label. Dispatch one `adversarial-debate` per Tier-1 finding, in parallel, each verifying only its own finding.
   - **Tier 2** — everything else. Runs through a single batched `adversarial-debate` call, same as before.
5. Ask targeted questions only when user-only context determines whether a finding is valid.
6. Run `/this-important strict` on **Tier 2 only** — Tier 1 already got per-finding verification and isn't re-filtered here.
7. Apply KEEP, DOWNGRADE, DROP, REVISE, PROMOTE, or `requires clarification` verdicts before presenting. PROMOTE and DOWNGRADE both require the same cited evidence (`file:line`, or `source`+`query`+`retrieved-at`) — neither is a bare severity opinion.

Verdict rule:

- `REQUEST_CHANGES` if any Tier-1 finding survives (or is PROMOTEd to) Critical after its per-finding verification. This is mechanical, not a fresh judgment call — Step 6 already independently verified it. Exception: a finding that's Critical only because verification returned `requires clarification` (couldn't be checked, not confirmed) surfaces as a blocking question instead of an automatic `REQUEST_CHANGES`.
- `APPROVE` when requirements are satisfied, no Tier-1 finding survives as Critical, and only minor nits or clearly optional Tier-2 suggestions remain.
- `COMMENT` when no Tier-1 finding survives as Critical but approval would overstate confidence: several substantive inline comments, unresolved requirements questions, insufficient context, stale/already-merged PR state, or explicit user instruction not to approve.

Output findings first, ordered by severity, with file:line evidence and concrete fixes. Make non-critical issues clearly non-blocking.
