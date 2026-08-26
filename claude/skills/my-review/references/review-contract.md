# Review Evidence Contract

Load this during triage, before final output, and when `implement-review` calls
`my-review`. It turns recurring review misses into observable acceptance checks.

## Coverage Manifest

Before fan-out, record the changed-file categories, active lenses, requirements
source, and source gaps. Security, QA, and the applicable general-reviewer
lenses are the baseline for every non-empty code diff. A requirements lens is
required when an issue, spec, or branch-name issue identifier exists. A lens may
be skipped only with a concrete diff-based reason in the manifest.

## Evidence Rules

- Resolve an issue identifier from the branch name before saying requirements
  are unavailable.
- Map every available acceptance criterion to the diff; record Covered, Partial,
  or Missing with file evidence before a verdict.
- A Critical finding needs a changed-line anchor and a causal explanation of
  how this diff introduced, regressed, or newly exposed the defect. Existing
  debt is not a merge blocker.
- A summary is not evidence. Research handoffs retain source paths and lines
  for load-bearing facts so receiving reviewers can inspect them.
- A resolved/deferred Finding Register entry is context, not suppression. Reopen
  it when later changed code touches its causal path or supplies new evidence.

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

## Re-review and Publication Boundaries

A re-review rebuilds the aggregate diff and current comment index; a prior
approval never narrows scope. Reviews remain read-only and never publish.
`REQUEST_CHANGES` requires at least one surviving verified Critical, High-risk
finding with an actionable inline anchor; unresolved threads, existing debt, a
Critical finding at Medium or Low risk, or a body-only objection do not
independently justify it.

`COMMENT` is reserved for a third-party PR: the PR author must differ from
the authenticated GitHub reviewer. Local, branch/range, local-issue,
embedded-local, self-authored PR, and unknown-ownership PR reviews must return
`REQUEST_CHANGES` or `APPROVE`. Non-blocking actionable findings and unresolved
questions remain visible under `APPROVE`; the binary verdict does not erase
them or inflate them into blockers.
