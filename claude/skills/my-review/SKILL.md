---
model: sonnet
effort: high
name: my-review
runner: skill-my-review
description: "Actionable local and PR review separating local code approval from required human acknowledgement."
when_to_use: "Use when the user asks to review their changes, diff, branch, or a GitHub PR."
---

# Code Review

Use `skill-my-review` for substantive review routing, evidence assembly,
whole-diff synthesis, targeted verification, and verdict construction. This
wrapper determines the source and authorization context, preserves the
user-facing publication boundary, and renders the runner's structured review
envelope.

## Dispatch

Resolve `ledger_path` only from `~/.claude/thoughts/shared/workflows/`. Normalize the request into `{ mode, review_relationship, target, base_ref, artifact_inputs, ledger_path, delivery_increment: infer, accepted_trigger_scope: none, confirmed_operational_scope: none, stage, authority: local_only, publication_authorization: none }` and dispatch it to `skill-my-review`.

- Infer `mode` as capture/promote, PR, branch/range, local, or local issue only from the supplied argument and current context; load the runner's retained shared routing references before resolving ambiguity.
- Set `review_relationship` to `local`, `self_authored_pr`, or `third_party_pr`. In PR mode, compare the PR author's login with the authenticated GitHub login; if either cannot be established, use `unknown_pr`, which is not eligible for `COMMENT`.
- Match a ledger by its recorded branch first, then its issue/slug context when branch metadata is unavailable. Set `ledger_path: none` only after that Claude Thoughts lookup finds no matching ledger; never search the repository for one.
- For `/my-workflow`, pass the approved plan/base/ledger context and stage number in embedded local mode. The runner returns the compact review envelope plus each finding's full description, stable key, and prior-ledger match, so the feedback loop can settle findings without making the user decode bookkeeping.
- Preserve an explicit delivery increment. Otherwise resolve it under
  `references/incremental-delivery.md`; never equate the full linked issue with
  the current change's promised scope.
- Present local pre-stage acknowledgements as item 1 without delaying the code
  verdict. For environment variables,
  feature flags, and migrations, accept only an
  explicit response confirming the exact readiness conditions in
  `references/change-set-risk.md`; a generic acknowledgement is insufficient.
  Append the corresponding `accepted` row from `references/finding-ledger.md`
  to the matching ledger, then resume with the confirmed operational scope.
  Keep other advisory acknowledgements in their separate accepted scope. When
  no ledger exists, re-dispatch with those scopes as invocation-local context
  only. Never infer confirmation from a general review request,
  auto/no-questions mode, a prior approval, or a response whose trigger contents
  differ.
  If no ledger exists, do not create one; disclose that confirmation cannot be
  durably suppressed.
- Do not invoke publication from this wrapper unless the user explicitly asks after reviewing the completed result. A runner may never publish a review, reply, resolve a thread, push, create/update a PR, or widen that authorization.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return overall change-set risk, the code verdict, readiness status, and the
current delivery increment first, then the coverage manifest and actionable
findings with file:line evidence and concrete author-controlled fixes, decisions,
or information requests, the single PR human acknowledgement or first-item local
pre-stage checklist when required,
verdict, questions, residual risk, requirements coverage including what is
intentionally deferred from this increment,
dropped findings, prior resolved/deferred/accepted matches, and the compact workflow-stage
envelope when embedded. Finding keys may follow the complete title, problem,
consequence, and fix, but may never replace them. Drop observations, preferences, and speculative concerns
that do not ask the author to do something concrete. Use `REQUEST_CHANGES` only
for verified findings that are both `Critical` and `High` risk. Local,
branch/range, local-issue, and embedded-local reviews always return the code
verdict; pre-stage human-acknowledgement items never replace it. PR reviews return
`needs_input` with approval pending when required operational readiness is
unconfirmed. `COMMENT` is
available only for an actual PR whose author differs from the authenticated
reviewer. Do not include raw lens or verifier transcripts.

Classify the aggregate diff using `references/change-set-risk.md` before fan-out.
A Low-risk set takes its fast-approval path. Migrations, environment variables,
feature flags, infrastructure/operations changes, other config, newly added
lint/tooling suppressions, and modifications to existing tests produce one
deduplicated human-acknowledgement item. New test files do not trigger it.
In PR mode, environment variables, feature flags, and migrations additionally
withhold approval until a human confirms their environment or staging
readiness. In local mode, report them as pre-stage checks and persist exact
confirmations separately from advisory acknowledgements so an older generic
acceptance can never satisfy operational readiness.
