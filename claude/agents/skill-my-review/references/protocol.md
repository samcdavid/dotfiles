# Protocol — my-review runner

This runner owns the routing, fan-out, evidence collection, and result-envelope boundary for `my-review`. The substantive review procedure and calibration sources are deliberately retained under `~/.claude/skills/my-review/references/` (or `~/.agents/skills/my-review/references/` under Codex), because existing lens and verifier agents consume them directly.

## Required shared sources

Read the retained `protocol.md` as the flow source of truth. Load its routing and finalization references for the selected mode. Do not copy or weaken the shared requirements, audit criteria, severity/risk/confidence axes, verifier tiers, templates, or learned-miss lifecycle here.

## Mechanical orchestration contract

1. Normalize the input mode and build the diff source of truth exactly as the shared protocol requires.
2. Classify aggregate change-set risk and scan human-review triggers using
   `change-set-risk.md`. If it qualifies for Low-risk fast approval, return terse
   `APPROVE` before fan-out.
3. Build at most one deduplicated human-review handoff containing every
   migration, environment-variable, feature-flag, config, infra/operations, and
   newly added lint/tooling-suppression anchor. Treat it as operational review
   context, not a finding. Track environment-variable, feature-flag, and
   migration tuples separately as approval-gating operational readiness.
4. In local mode, compare advisory tuples with the latest accepted
   `review-handoff.local-sensitive-changes` scope and operational tuples with
   `review-handoff.operational-readiness` plus the wrapper's invocation-local
   scopes. Present one explicit confirmation as review item 1 when uncovered.
   The wrapper records only an exact acknowledgement/confirmation in the ledger
   and re-dispatches; never infer it or write the ledger in this runner. Continue
   the substantive review while confirmation is pending.
5. Dispatch research and active lens reviewers, then merge and dedupe only their flat findings.
6. Run one bounded whole-diff synthesis pass after lens compilation. It may emit
   only interaction candidates grounded in the diff and research evidence; every
   candidate must enter the same verifier route as lens findings.
7. Route every finding to exactly one isolated verifier from its severity, risk,
   and confidence. Re-dispatch low-tier escalations to the high tier; do not
   self-adjudicate them.
8. Apply `review-contract.md`'s Actionability Gate after verification. A finding
   or question survives only when it requests a concrete author-controlled
   change, decision, or specific information tied to a changed-line risk.
9. Compute `REQUEST_CHANGES` mechanically only from verified Critical, High-risk
   findings. When operational readiness remains unconfirmed, return
   `needs_input` with `approval_status: pending_human_confirmation`; never return
   `APPROVE`. A third-party PR may use `COMMENT`, while other relationships have
   no verdict until confirmation. Once confirmed, return `APPROVE` for local,
   self-authored PR, and unknown-ownership reviews when no blocker survives.
   Only a third-party PR may choose between `APPROVE` and `COMMENT`; delegate
   that confirmed-readiness choice to `adversarial-debate`.
10. Enforce `review-contract.md` before returning the compact result envelope to
   the wrapper, `implement-review`, or `my-workflow`.

Never bypass the outer wrapper's publication boundary. Never pass raw subagent transcripts to a downstream stage.
