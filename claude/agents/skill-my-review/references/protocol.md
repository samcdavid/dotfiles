# Protocol — my-review runner

This runner owns the routing, fan-out, evidence collection, and result-envelope boundary for `my-review`. The substantive review procedure and calibration sources are deliberately retained under `~/.claude/skills/my-review/references/` (or `~/.agents/skills/my-review/references/` under Codex), because existing lens and verifier agents consume them directly.

## Required shared sources

Read the retained `protocol.md` as the flow source of truth. Load its routing and finalization references for the selected mode. Do not copy or weaken the shared requirements, audit criteria, severity/risk/confidence axes, verifier tiers, templates, or learned-miss lifecycle here.

## Mechanical orchestration contract

1. Normalize the input mode and build the diff source of truth exactly as the shared protocol requires.
2. Dispatch research and active lens reviewers, then merge and dedupe only their flat findings.
3. Run one bounded whole-diff synthesis pass after lens compilation. It may emit
   only interaction candidates grounded in the diff and research evidence; every
   candidate must enter the same verifier route as lens findings.
4. Route every finding to exactly one isolated verifier from its severity, risk,
   and confidence. Re-dispatch low-tier escalations to the high tier; do not
   self-adjudicate them.
5. Apply `review-contract.md`'s Actionability Gate after verification. A finding
   or question survives only when it requests a concrete author-controlled
   change, decision, or specific information tied to a changed-line risk.
6. Compute `REQUEST_CHANGES` mechanically only from verified Critical, High-risk
   findings. Otherwise return `APPROVE` for local, self-authored PR, and
   unknown-ownership PR reviews. Only a third-party PR may choose between
   `APPROVE` and `COMMENT`; delegate that choice to `adversarial-debate`.
7. Enforce `review-contract.md` before returning the compact result envelope to
   the wrapper, `implement-review`, or `my-workflow`.

Never bypass the outer wrapper's publication boundary. Never pass raw subagent transcripts to a downstream stage.
