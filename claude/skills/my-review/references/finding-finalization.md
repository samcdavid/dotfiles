# Finding Finalization

Load this after lens reviewers return.

This stage is skipped for `change-set-risk.md`'s Low-risk fast approval. The
PR-only human acknowledgement is finalized separately from findings: one inline
annotation for the whole PR, deduped by substance and containing all trigger
anchors. Do not verifier-route it or apply the Actionability Gate to it.

The local pre-stage human-acknowledgement checklist is likewise finalized separately
from findings. It must be review item 1 when uncovered and bypasses
verifier/importance routing. Advisory acknowledgements and
operational-readiness confirmations use separate stable keys. Continue
substantive review and always return the independent local code verdict when
either is pending.

1. Merge duplicate findings across lenses. Keep the **highest** severity, the **highest** risk, and the **lowest** confidence of the merged pair — a finding two lenses read differently gets verified harder, not averaged.
2. Dedupe against existing PR comments and threads.
3. Confirm every finding carries all three levels from `references/finding-axes.md` — severity (per the shared review rule), risk, and confidence. Lens reviewers assign these; do not silently re-label them here. A fragment missing them means the reviewer ran an old contract — re-dispatch it rather than filling the levels in yourself.
4. Verify only candidates that satisfy `(severity == Critical OR risk == High) AND confidence >= 80` with `finding-verifier-high`. Use `finding-verifier-low` only for an explicit `needs_confirmation` request with a named unresolved fact, exact query, and code-verdict or Opus-eligibility consequence. Every other finding is not independently verified and cannot affect the verdict.
5. A targeted-Sonnet `requires clarification` becomes a targeted question. Re-route only a cited revision that satisfies the exact Opus predicate; otherwise do not add another verifier pass.
7. Ask targeted questions only when user-only context determines whether a finding is valid.
8. Apply `review-contract.md`'s Actionability Gate to every surviving finding and question. Drop anything without a concrete author-controlled fix, decision, or specific information request tied to a changed-line risk; do not move it into residual-risk or deep-dive prose.
9. Run `/this-important strict` on unverified non-blocking findings only; Opus-verified findings already got the deep pass.
10. Apply KEEP, DOWNGRADE, DROP, REVISE, PROMOTE, or `requires clarification` verdicts before presenting. PROMOTE and DOWNGRADE both require the same cited evidence (`file:line`, or `source`+`query`+`retrieved-at`) — neither is a bare severity opinion.
11. For every Critical requirements finding, record the clearing condition in the
   blocker ledger. A feature gate, dark implementation, or related follow-up
   ticket may remove runtime risk but does **not** clear omitted acceptance
   criteria without an explicit requirement amendment. Mark this `Scope Decision
   Required`; do not translate it into repeated implementation requests.

Verdict rule:

- `REQUEST_CHANGES` only if a finding survives (or is PROMOTEd to) both Critical **and** High risk after per-finding verification. This is mechanical, not a fresh judgment call — Step 6 already independently verified it. A finding needing clarification surfaces as a blocking question, never an automatic `REQUEST_CHANGES`.
- In local, branch/range, local-issue, and embedded-local reviews: always return
  `APPROVE` when no Critical High-risk finding survives, otherwise
  `REQUEST_CHANGES`. Outstanding pre-stage human-acknowledgement items remain visible but
  never suppress this code verdict. Actionable non-blocking findings and
  unresolved questions cannot produce `COMMENT` or be inflated into
  `REQUEST_CHANGES`.
- In self-authored and unknown-ownership PR reviews: `APPROVE` whenever no
  Critical High-risk finding survives and operational readiness is confirmed.
  If readiness is unconfirmed, return `needs_input` with approval pending and no
  PR verdict.
- In a third-party PR review: `APPROVE` when requirements are satisfied and all remaining findings are Low risk; `COMMENT` when Medium/High-risk non-blocking feedback or unresolved requirements/context remains, the PR is stale/already merged, or the user explicitly asks not to approve.
- A pending advisory acknowledgement counts as unresolved context for a third-party PR
  and therefore produces `COMMENT`. Pending operational readiness forbids
  PR `APPROVE`; use `COMMENT` for a third-party PR and no verdict with
  `needs_input` for other PR relationships. It never independently produces
  `REQUEST_CHANGES` and never suppresses a local code verdict.

For a re-review, report the blocker ledger delta: cleared, still open, regressed,
or newly verified, plus any accepted local human-acknowledgement scope reused or expanded.
Do not repeat a prior blocking finding or accepted confirmation verbatim when its
covered state has not changed.

Output actionable findings first, ordered by severity then risk, with file:line evidence and concrete fixes, decisions, or information requests. Make non-critical issues clearly non-blocking. There is no "What's Good" section — lens reviewers no longer return grounded positives, so writing one would mean inventing unverified praise.
