# Protocol — skill-address-pr-feedback

This runner owns evidence-backed feedback triage and locally verified fixes.
The wrapper owns user decisions and every GitHub mutation. Keep context scoped:
load the reference named for the current stage, not the entire reference set.

## Start

Read `mode-semantics.md`, then determine the feedback source. Look once for a
branch workflow ledger; load `workflow-ledger-context.md` only when one exists.
Its settled requirements, decisions, and Finding Register are evidence. Do not
create a ledger merely for feedback.

In PR mode, load `feedback-collection.md`; use its filtered GitHub queries and
the PR head/diff as truth. In local mode, use the full branch diff against the
provided base and the supplied findings. In either mode, exclude resolved or
already-addressed items and group comments sharing one root cause.

## Triage

Load `feedback-triage.md` after collecting pending items. Every item needs
evidence from the relevant code, test, requirement, or authoritative API docs
before it is accepted, deferred, or challenged.

For every item, extract the relevant code facts and classify it from the
available evidence. The runner retains final judgment and independently checks
citations and classification before using them.

Load `pushback-patterns.md` only for a proposed pushback, deferral, or
substantive design rationale. Do not load its examples for an ordinary confirmed
fix or factual question. Run `adversarial-screen` only when the conclusion is
uncertain, challenges a reviewer, changes behavior, or relies on a non-obvious
causal claim. Escalate to `adversarial-debate` only for material risk,
contradictory evidence, or a disputed scope decision. Apply `this-important`
only to a credible, non-blocking item whose fix-versus-deferral priority remains
genuinely unclear; it never downgrades a verified blocking concern.

Return PR triage to the wrapper for confirmation. In local mode, proceed with
the scoped, substantive findings; nits remain visible but do not consume a fix
cycle. A requirement-reducing workaround is always `Scope Decision Required`;
wait for an explicit amendment instead of treating a related ticket as one.

## Fix and validate

After confirmed scope, load `fix-planning.md`. Turn each confirmed behavior
into one bounded `my-implement` phase with an honest RED test and mechanical
success criteria; send genuinely non-behavioral work through its direct-edit
mode. `my-implement` performs the edit. Fixes are sequential, stay
within their allowed paths, receive independent diff/check verification, and
land as separate local commits only through `Skill(commit)`.

Run the narrowest affected checks while iterating, then the combined
build/compile, lint/format, and test gate from `execution-contract.md` once.
Never call work complete if a required check is failed or inconclusive.

Use post-fix review in proportion to risk:

- Documentation, comments, formatting, and other no-behavior direct edits:
  independent diff inspection plus their targeted check; no `my-review` pass.
- Ordinary behavioral or multi-file fixes: one `my-review` pass after the
  combined gate; repair only a substantive result and re-review once.
- Security, data, migration, public-contract, or otherwise high-risk fixes:
  retain the existing repair loop, capped at three total `my-review` passes.

## Respond and return

Load `replies-and-publishing.md` only when drafting replies or an
`external_action_requested` envelope. Load `self-audit-checklist.md` only after
the final validation/review pass. Responses state the evidence and exact fix or
reason, and never claim a remote action happened.

If a ledger exists, append the feedback round and evidence-backed
resolved/deferred dispositions according to `workflow-ledger-context.md`.
Return compact triage/fix/validation evidence, commits, surviving concerns, and
the exact external-action envelope. The runner never pushes, replies, resolves,
or re-requests review.
