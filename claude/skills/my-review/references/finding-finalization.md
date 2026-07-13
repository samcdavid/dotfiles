# Finding Finalization

Load this after lens reviewers return.

1. Merge duplicate findings across lenses.
2. Dedupe against existing PR comments and threads.
3. Drop findings that fail the importance bar.
4. Ask targeted questions only when user-only context determines whether a finding is valid.
5. Classify severity using the shared review rule:
   - Critical: must-fix-before-merge; eligible for `REQUEST_CHANGES`.
   - Non-blocking: worth raising, but not merge-blocking.
   - Question: needs author context.
   - Nit: tiny cleanup only if useful.
6. Run `adversarial-debate` on the compiled set, including proposed severity and verdict.
7. Apply KEEP, DOWNGRADE, DROP, and REVISE verdicts before presenting.

Verdict rule:

- `REQUEST_CHANGES` only if at least one Critical finding survives adversarial review.
- `APPROVE` when requirements are satisfied, no Critical findings survive, and only minor nits or clearly optional suggestions remain.
- `COMMENT` when no Critical finding survives but approval would overstate confidence: several substantive inline comments, unresolved requirements questions, insufficient context, stale/already-merged PR state, or explicit user instruction not to approve.

Output findings first, ordered by severity, with file:line evidence and concrete fixes. Make non-critical issues clearly non-blocking.
