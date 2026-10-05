# Protocol — my-review runner

This runner owns routing, dispatch, evidence collection, and the result-envelope boundary for `my-review`. The substantive review procedure and calibration sources are deliberately retained under `~/.claude/skills/my-review/references/` (or `~/.agents/skills/my-review/references/` under Codex), because the whole-diff worker and verifier agents consume them directly.

## Required shared sources

Read the retained `protocol.md` as the flow source of truth. Load its routing and finalization references for the selected mode. Do not copy or weaken the shared requirements, audit criteria, severity/risk/confidence axes, verifier tiers, templates, or learned-miss lifecycle here.

## Mechanical orchestration contract

1. Normalize the input mode and build the diff source of truth exactly as the shared protocol requires.
2. Classify aggregate change-set risk and scan human-acknowledgement triggers using
   `change-set-risk.md`. If it qualifies for Low-risk fast approval, return terse
   `APPROVE` before review dispatch.
3. Build at most one deduplicated human acknowledgement containing every
   migration, environment-variable, feature-flag, config, infra/operations, and
   newly added lint/tooling-suppression anchor, plus edits to test cases that
   existed at the comparison base. Newly added tests, including new test cases
   in existing files, do not trigger it. Treat the
   acknowledgement as context, not a finding. Track environment-variable, feature-flag, and
   migration tuples separately as operational readiness.
4. In local mode, compare advisory tuples with the latest accepted
   `review-handoff.local-sensitive-changes` scope and operational tuples with
   `review-handoff.operational-readiness` plus the wrapper's invocation-local
   scopes. List uncovered tuples on the tracked pre-stage checklist; never
   prompt for them. The wrapper records only an exact volunteered
   acknowledgement/confirmation in the ledger; never infer it or write the
   ledger in this runner.
5. Dispatch focused research only for unanswered facts, then exactly one
   `general-reviewer` with the full aggregate diff and every activated coverage
   criterion. It applies the corresponding checklists in one retained context
   and returns a consolidated finding set.
6. Run one bounded whole-diff synthesis pass after the whole-diff worker. Route pure author-information or author-decision candidates straight to prepared author questions under `change-set-risk.md`. Persist the remaining candidate set, then invoke `walk-through` one item at a time. Until each item is dismissed, retained unverified, queued for an author question, or explicitly authorized for targeted research, return `awaiting_user_triage` with no verdict or investigator dispatch.
7. After the complete walk-through, drop duplicates and candidates missing a changed-line anchor, causal link, or concrete author-controlled action. Route only explicitly authorized candidates: send to Sol only findings satisfying `(severity == Critical OR risk == High) AND confidence >= 80`; use Terra only for complete `needs_confirmation` requests with the named fact, exact query, and code-verdict or Opus-eligibility consequence. All others are explicitly unverified and cannot affect the verdict.
8. Apply `review-contract.md`'s Actionability Gate after verification. A finding
   or question survives only when it requests a concrete author-controlled
   change, decision, or specific information tied to a changed-line risk.
9. Compute `REQUEST_CHANGES` mechanically only from verified Critical, High-risk
   findings. Local review always returns an independent code verdict and lists
   acknowledgement items separately. For PR review, unconfirmed operational
   readiness sets `approval_status: pending_author_confirmation` and rides in
   the prepared acknowledgement. A third-party PR then uses `COMMENT`;
   self-authored and unknown-ownership PRs return `APPROVE` when no blocker
   survives. Never return `needs_input` for acknowledgement, confirmation, or
   clarification items.
   Only a third-party PR may choose between `APPROVE` and `COMMENT`; challenge
   that confirmed-readiness choice with `adversarial-screen` in `decision` mode
   and the current review-bundle fingerprint. A material risk it identifies
   becomes a normal finding and reaches Sol only when Critical or High risk.
10. Enforce `review-contract.md` before returning the compact result envelope to
   the wrapper, `implement-review`, or `my-workflow`.

Never bypass the outer wrapper's publication boundary. Never pass raw subagent transcripts to a downstream stage.
