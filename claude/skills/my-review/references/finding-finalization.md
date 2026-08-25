# Finding Finalization

Load this after lens reviewers return.

1. Merge duplicate findings across lenses. Keep the **highest** severity, the **highest** risk, and the **lowest** confidence of the merged pair — a finding two lenses read differently gets verified harder, not averaged.
2. Dedupe against existing PR comments and threads.
3. Confirm every finding carries all three levels from `references/finding-axes.md` — severity (per the shared review rule), risk, and confidence. Lens reviewers assign these; do not silently re-label them here. A fragment missing them means the reviewer ran an old contract — re-dispatch it rather than filling the levels in yourself.
4. Verify **every** finding individually (see `references/protocol.md` Step 6) — one agent per finding, all dispatched in one parallel message, none batched. Tier is mechanical:
   - `finding-verifier-high` — severity is Critical, **or** risk is High, **or** confidence is Low on a non-Nit/non-Question finding.
   - `finding-verifier-low` — everything else.
5. Re-dispatch any low-tier `requires escalation` to `finding-verifier-high`. An escalation is an unverified finding, not a disproven one — never resolve it in the main window and never treat it as a DROP.
6. Ask targeted questions only when user-only context determines whether a finding is valid.
7. Run `/this-important strict` on **low-tier findings only** — high-tier findings already got the deep per-finding pass and aren't re-filtered here.
8. Apply KEEP, DOWNGRADE, DROP, REVISE, PROMOTE, or `requires clarification` verdicts before presenting. PROMOTE and DOWNGRADE both require the same cited evidence (`file:line`, or `source`+`query`+`retrieved-at`) — neither is a bare severity opinion.
9. For every Critical requirements finding, record the clearing condition in the
   blocker ledger. A feature gate, dark implementation, or related follow-up
   ticket may remove runtime risk but does **not** clear omitted acceptance
   criteria without an explicit requirement amendment. Mark this `Scope Decision
   Required`; do not translate it into repeated implementation requests.

Verdict rule:

- `REQUEST_CHANGES` only if a finding survives (or is PROMOTEd to) both Critical **and** High risk after per-finding verification. This is mechanical, not a fresh judgment call — Step 6 already independently verified it. A Critical finding at Medium or Low risk gets `COMMENT`; a finding needing clarification surfaces as a blocking question, never an automatic `REQUEST_CHANGES`.
- `APPROVE` when requirements are satisfied and only minor nits or clearly optional suggestions remain.
- `COMMENT` whenever actionable feedback, unresolved requirements questions, insufficient context, stale/already-merged PR state, or explicit user instruction not to approve remains.

For a re-review, report the blocker ledger delta: cleared, still open, regressed,
or newly verified. Do not repeat a prior blocking finding verbatim when its state
has not changed.

Output findings first, ordered by severity then risk, with file:line evidence and concrete fixes. Make non-critical issues clearly non-blocking. There is no "What's Good" section — lens reviewers no longer return grounded positives, so writing one would mean inventing unverified praise.
