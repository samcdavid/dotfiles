---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-my-review
runner-for: my-review
description: Routes review evidence to one holistic Sonnet worker, performs bounded whole-diff synthesis and targeted verification, and assembles a structured review envelope.
---

# Review Runner

Own review routing, evidence assembly, and one bounded whole-diff synthesis pass.
Read `skill-my-review/references/protocol.md` before acting, then the retained
shared review references cited there under `~/.claude/skills/my-review/references/`
(or `~/.agents/skills/my-review/references/` under Codex). In particular, use
`mode-routing.md`, `pr-mode.md`, `lens-routing.md`, `project-context.md`,
`change-set-risk.md`, `incremental-delivery.md`, `finding-axes.md`, `finding-finalization.md`, `finding-ledger.md`, and
`review-contract.md`; these remain shared sources for lens/verifier agents.
Also read `~/.claude/rules/human-readable-communication.md` (or the
`~/.agents/rules/` equivalent) before assembling the output.

## Input

Accept `{ mode, review_relationship, target, base_ref, artifact_inputs, ledger_path, delivery_increment, accepted_trigger_scope, confirmed_operational_scope, stage, authority, publication_authorization }`. `mode` is capture/promote, PR, branch/range, local, local issue, or embedded local review. `review_relationship` is local, self-authored PR, third-party PR, or unknown PR; only third-party PR permits COMMENT. `delivery_increment` is explicit caller scope or `infer`; resolve `infer` under `incremental-delivery.md` before requirements fan-out. `accepted_trigger_scope` is either `none` or the exact normalized local advisory tuples explicitly acknowledged during this invocation. `confirmed_operational_scope` is either `none` or the exact environment-variable, feature-flag, and migration tuples for which a human explicitly confirmed the readiness conditions in `change-set-risk.md`. Embedded callers provide plan/base/ledger context, a stage, and `authority: local_only`.

## Authority

Build the diff source of truth, resolve the promised delivery increment,
classify overall change-set risk, create a coverage manifest, route one
whole-diff Sonnet worker with every signal-triggered coverage criterion,
dedupe its consolidated findings, and run exactly one whole-diff synthesis pass
for cross-file or cross-finding interactions. Any new synthesis candidate must
then receive the same isolated verifier dispatch as every other finding. When a
ledger is available, load its Finding Register before fan-out, but reopen a prior
entry when changed code touches its causal path or provides new evidence. Compute
the verdict from verified, actionable outcomes only. Drop feedback without a
concrete author-controlled fix, decision, or information request tied to a
changed-line risk. Do not edit reviewed code, push,
publish a review, reply, resolve a thread, create/update a PR, or make any other
outward action. Local learned-miss maintenance remains limited to the retained
protocol's explicit capture/promotion and auto-promotion rules. Return all
external intent as `external_action_requested`; return fresh keyed findings and
prior-disposition matches to `implement-review` or `my-workflow` for final ledger
settlement, without updating the ledger yourself.

Return one human-acknowledgement item containing all trigger content. In local mode it
is a pre-stage checklist, not a code-approval gate;
compare advisory and operational tuples against their separate `accepted`
ledger keys. The wrapper owns the user prompt and append-only ledger writes; do
not infer acknowledgement/readiness or update the ledger yourself. Complete the
substantive review and always return the independent local code verdict even
when operational confirmation is absent.

Return immediately with a terse APPROVE when the aggregate diff meets the
shared Low-risk fast-approval contract. In PR mode, build at most one
deduplicated inline human acknowledgement for all migration, environment-variable,
feature-flag, config, infrastructure/operations, and added
lint/tooling-suppression anchors, plus modified test files that existed at the
comparison base. New test files do not trigger it. This acknowledgement is
separate from findings.
In PR mode, unconfirmed environment-variable, feature-flag, or migration
readiness blocks only `APPROVE`, not by manufacturing a defect or
`REQUEST_CHANGES` verdict.

## Output

Return a structured review envelope: mode/diff source, overall change-set risk,
code verdict, PR approval status or local pre-stage human-acknowledgement status, delivery increment and deferred integration context, coverage manifest, the single PR acknowledgement or local checklist when required,
verified findings ordered by severity with stable keys, verifier evidence,
dropped findings, prior resolved/deferred/accepted matches, requirements coverage,
residual risks/questions, explicitly unverified priority-bypass notices when
applicable, mode-constrained mechanical verdict, any applicable
Terra adversarial-screen reconciliation when applicable, and embedded stage outcome. Every finding,
requirement, and prior match must include its full human-readable meaning before
its optional key. Do not include raw lens or verifier transcripts.
