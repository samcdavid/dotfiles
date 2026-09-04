# Protocol — skill-address-pr-feedback

This runner owns evidence-backed feedback triage and locally verified fixes.
The wrapper owns user decisions and every GitHub mutation. Keep context scoped:
load the reference named for the current stage, not the entire reference set.

## Start

Read `mode-semantics.md`, then determine the feedback source. Look once for a
branch workflow ledger; load `workflow-ledger-context.md` only when one exists.
Its settled requirements, decisions, and Finding Register are evidence. Do not
create a ledger merely for feedback.

At triage completion, each combined validation gate, and each review pass,
record the compact handoff required by `context-checkpoint.md`. Use the branch
workflow ledger when it exists; otherwise write a self-contained handoff under
`~/.claude/thoughts/shared/feedback/` (or the equivalent active artifact root)
and return its path as `feedback_handoff`. Include only the PR/branch and
evidence fingerprint, root-cause batch, settled dispositions, commits, final
command statuses, review outcome, and next action. Resume from that handoff
instead of re-collecting a full diff or prior logs. End and resume in fresh
context before roughly 80k retained tokens.

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
into a bounded root-cause batch. Compatible comments may share one phase only
when they repair the same cause, use the same focused test setup and allowed
paths, and retain one behavior contract. Independent causes remain separate
batches. A behavioral batch has an honest RED test and mechanical success
criteria; genuinely non-behavioral work uses direct-edit mode.
`my-implement` performs the edit. Fixes are sequential, stay within their
allowed paths, receive independent diff/check verification, and land as
separate local commits only through `Skill(commit)`.

Before dispatching the normal repair path, classify a batch for the **feedback
fast lane**. Default to the fast lane whenever eligibility is ambiguous; route
to the full `my-implement` path only when a listed risk factor is actually
present in that batch's behavior, not merely nearby in the file. It is eligible
when it is one confirmed root cause, changes at most four existing
source/test/doc files, has no migration, auth, permission, security,
public-contract, dependency, configuration, concurrency, external-I/O, or
requirements-scope impact, and has a focused proving check. Dispatch this
pre-confirmed micro-fix through `my-quick` with the triage evidence, allowed
paths, and check. Its normal tripwires still apply; any tripwire, failed check,
or scope expansion exits the fast lane and returns here for the normal path.
Never use the fast lane for a disputed, deferred, or partially-correct item.

Run the narrowest affected checks while iterating, then the combined
build/compile, lint/format, and test gate from `execution-contract.md` once.
Never call work complete if a required check is failed or inconclusive.

Use post-fix review in proportion to risk. Default every batch to the lowest
tier its classification qualifies for; escalate a tier only when a specific
risk factor is present in that batch, never as a blanket default:

- Feedback-fast-lane fixes, documentation, comments, formatting, and other
  no-behavior direct edits: independent diff inspection plus their focused
  check and `my-quick` self-review where applicable; no `my-review` pass.
- Medium-risk behavioral or multi-file fixes: one `my-review` pass after the
  combined gate; repair only a substantive result and re-review once. This is
  the default tier for ordinary review comments — do not apply the high-risk
  loop without a named security/data/migration/public-contract factor.
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
