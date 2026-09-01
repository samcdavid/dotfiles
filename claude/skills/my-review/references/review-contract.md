# Review Evidence Contract

Load this during triage, before final output, and when `implement-review` calls
`my-review`. It turns recurring review misses into observable acceptance checks.

## Coverage Manifest

Before fan-out, record the changed-file categories, active lenses, requirements
source, resolved delivery increment, and source gaps. Except for a valid Low-risk fast approval, Security,
QA, and the applicable general-reviewer lenses are the baseline for every
non-empty code diff. A requirements lens is
required when an issue, spec, or branch-name issue identifier exists. A lens may
be skipped only with a concrete diff-based reason in the manifest.

Also classify the aggregate diff under `change-set-risk.md`. Low-risk fast
approval is valid only after requirements, existing-thread, and human-acknowledgement
trigger checks pass; diff size or an empty candidate-finding list is not enough.

## Evidence Rules

- Build and reuse one fingerprinted evidence bundle under
  `~/.claude/rules/evidence-bundles.md` (or `~/.agents/rules/` under Codex).
  Rebuild it only when its source identity, manifest, requirements source, or
  feedback index changes.
- Resolve an issue identifier from the branch name before saying requirements
  are unavailable.
- Map every available acceptance criterion to the declared delivery increment
  and diff. Record its delivery classification plus Covered, Partial, Missing,
  or Deferred outside increment with evidence before a verdict. Do not turn
  intentionally deferred eventual-feature work into a current defect.
- A change may be approved as internal groundwork or a partial delivery when
  the declared increment is coherent, safe, tested, and accurately scoped.
  Immediate user visibility and completion of the entire linked issue are not
  approval requirements.
- A Critical finding needs a changed-line anchor and a causal explanation of
  how this diff introduced, regressed, or newly exposed the defect. Existing
  debt is not a merge blocker.
- A summary is not evidence. Research handoffs retain source paths and lines
  for load-bearing facts so receiving reviewers can inspect them.
- A resolved/deferred Finding Register entry is context, not suppression. Reopen
  it when later changed code touches its causal path or supplies new evidence.
- An `accepted` row suppresses only the local human confirmation whose normalized
  trigger tuples and stable key it covers. Advisory acknowledgement under
  `review-handoff.local-sensitive-changes` never confirms operational readiness
  under `review-handoff.operational-readiness`. Neither suppresses defect
  analysis or ordinary findings, and new/changed trigger content requires fresh
  confirmation.

## Actionability Gate

Every surfaced finding must tell the author exactly what action would resolve it:
a concrete code/test/documentation change, an explicit product or scope decision,
or specific information only the author can provide. It must also state the
changed-line risk that action addresses. A code example is optional when the
written fix is already unambiguous.

Drop observations, generalized advice, preferences, praise, speculative future
concerns without a present changed-line consequence, and questions that do not
name the decision or information needed. Do not preserve them as residual risk,
body commentary, deep-dive prose, or a downgraded Nit. Deep-dive sections may
summarize evidence, but may not introduce unactionable feedback that bypassed
the finding gate.

## Bounded Whole-Diff Synthesis

After lens compilation and before verifier routing, inspect the full diff,
requirements, Coverage Manifest, and cited research evidence once for
cross-file interactions: contract mismatches, conflicting changes, or a
requirement whose implementation and test evidence disagree. Do not repeat lens
checklists or propose broad cleanup. Each synthesis candidate needs a
changed-line causal link, severity/risk/confidence, and normal isolated
verification; synthesis never changes the verdict directly.

## Final Integrity Gate

Immediately before returning a PR envelope, refresh both the GraphQL review
thread index and the filtered REST review-comment index. Drop substantive
duplicates, including bot comments anchored at a different line. Re-run the
Actionability Gate, then recompute the verdict. Do not publish or recommend
`REQUEST_CHANGES` unless at least one surviving Critical, High-risk finding
passes every evidence rule above.

When `change-set-risk.md` identifies PR human-acknowledgement triggers, the envelope has
exactly one deduplicated inline acknowledgement containing every relevant
anchor. This acknowledgement is not a finding, does not pass through the
Actionability Gate or verifiers, and is never repeated in body commentary.
Deduplicating the request does not confirm the external readiness facts.

When the same triggers appear in local mode, the first review item is one
pre-stage acknowledgement checklist for all uncovered trigger tuples. Continue substantive
review and always return the independent code verdict. Human confirmation is
still required before promotion to the affected staging or production
environment, but it does not gate local code approval. Generic acknowledgement
is sufficient only for the separate advisory scope. The matching ledger keys'
append-only `accepted` rows are the only durable dedupe signals; auto mode and
conversation inference are not substitutes.

## Re-review and Publication Boundaries

A re-review rebuilds the aggregate diff and current comment index; a prior
approval never narrows scope. Reviews never edit reviewed code or publish. The
only additional local write is the outer wrapper's append-only accepted
confirmation row under `change-set-risk.md` when the user explicitly approves it.
`REQUEST_CHANGES` requires at least one surviving verified Critical, High-risk
finding with an actionable inline anchor; unresolved threads, existing debt, a
Critical finding at Medium or Low risk, or a body-only objection do not
independently justify it.

`COMMENT` is reserved for a third-party PR: the PR author must differ from the
authenticated GitHub reviewer. Local, branch/range, local-issue, and
embedded-local reviews always return a code verdict of `REQUEST_CHANGES` or
`APPROVE`; outstanding pre-stage checks remain visible separately.
Self-authored and unknown-ownership PR reviews may return no verdict with
`needs_input` while operational readiness is unconfirmed. Non-blocking
actionable findings and unresolved questions remain visible under `APPROVE`;
the verdict rule does not erase them or inflate them into blockers.
