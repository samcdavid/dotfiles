# Change-Set Risk and Human Acknowledgement

Load during triage, before review dispatch. This classifies the aggregate set of
changes, not individual findings. Finding `Risk` in `finding-axes.md` remains a
separate likelihood-and-blast-radius score.

## Overall change-set risk

Record `overall_change_risk: Low | Medium | High` with one diff-grounded
rationale.

- **Low** — the aggregate diff is small, local, reversible, and does not alter
  runtime behavior, public or persistence contracts, data, authorization,
  dependencies, deployment/configuration, infrastructure, or requirements. No
  human-acknowledgement trigger below is present and no source gap or ambiguity could
  change that classification. Typical examples are documentation, comments,
  snapshots/fixtures that mirror an already-reviewed behavior, or a mechanical
  refactor whose equivalence is directly visible.
- **Medium** — the diff changes behavior or operational shape in a contained,
  reversible way, or needs human acknowledgement, but has no evident wide or
  irreversible failure mode.
- **High** — the diff touches a wide, privileged, irreversible, externally
  coupled, or difficult-to-roll-back surface: authentication/authorization,
  sensitive data, destructive or large-table migrations, cross-service/public
  contracts, production infrastructure, broad dependency/runtime upgrades, or
  a launch-critical requirement.

Do not infer `Low` from line count, author seniority, passing tests, or an
absence of initial findings. If uncertain between levels, choose the higher one
and state the missing fact.

## Low-risk fast approval

When `overall_change_risk` is `Low`, stop after scope/intent validation and
existing-comment dedupe. Return a terse `APPROVE` with the classification and
rationale. Do not dispatch research agents, the whole-diff worker, or verifier
agents; do not manufacture suggestions,
or use `COMMENT`. This path is unavailable when requirements included in the
declared delivery increment are missing or partial, when the increment is
consequentially unclear, an existing unresolved thread concerns the changed
lines, or any human-acknowledgement trigger is present. Requirements explicitly deferred
from this increment do not disable the fast path by themselves.

## Human-acknowledgement triggers

Scan aggregate diff changes in PR and local modes. Build two disjoint trigger
sets.

`operational_readiness_triggers` require explicit human confirmation, tracked
as an author request in PR mode and a pre-stage checklist item in local review:

- database/schema/data migrations or backfills;
- new or changed runtime environment-variable references, declarations, or
  deployment values; and
- new or changed feature-flag definitions, lookups, defaults, rollout values,
  or targeting configuration.

`advisory_acknowledgement_triggers` still require human acknowledgement, but never
need deployment-state confirmation:

- other secrets/config lookups or deployment-time settings not already captured
  as environment variables or feature flags;
- infrastructure and operations surfaces such as Terraform/Pulumi/CloudFormation,
  Kubernetes/Helm, deploy manifests, CI/CD workflows, service/resource limits,
  networking, permissions, and production config;
- newly added linter, formatter, type-checker, or static-analysis ignores and
  suppressions, including file/config exclusions and inline disable comments;
  and
- edits to a test case that existed at the comparison base: a changed or
  deleted test body, assertion, expectation, or skip/pending marker, or a
  changed/deleted shared setup, fixture, or helper that existing test cases
  already use. Judge at the test-case level, not the file level: purely
  additive changes — new test files, new test definitions in existing files,
  and new setup/fixtures/helpers/imports only those new tests use — do not
  trigger acknowledgement, because they cannot weaken a protection that already
  existed.

These signals need deliberate human acknowledgement; the operational subset
also requires repository-external knowledge. They are not automatic defects,
do not acquire finding severity or risk, and do not independently justify
`REQUEST_CHANGES`. The operational-readiness set keeps a third-party PR at
`COMMENT` because the agent cannot verify deployment state or staging
execution. In every other relationship it is reported separately and never
changes the code verdict.

Normalize every trigger as `{ category, path, changed_content_digest }`, where
`category` is `migration`, `environment-variable`, `feature-flag`, `config`,
`infra-ops`, `lint-tooling-suppression`, or `modified-existing-test`. For an
existing test, establish that the path exists at the comparison base and digest
its semantic added/deleted content without hunk line numbers; a newly added test
path is not a trigger. For other categories, the digest covers the
added/modified trigger content without its line number. Sort and deduplicate
these tuples. Line movement alone must not manufacture a new trigger; new or
materially changed trigger content must.

## Operational readiness clearing condition

Repository evidence cannot establish operational readiness, so the review
tracks each applicable condition as an author-directed request instead of
asking the user to resolve it:

- **Environment variables:** the appropriate value has been set in every
  staging and production environment.
- **Feature flags:** the appropriate flag value/configuration has been set in
  every staging and production environment.
- **Migrations/backfills:** the changed migration or backfill has been tested
  successfully in staging.

A generic acknowledgement, request to continue, prior approval, passing local
tests, or the existence/deduplication of an acknowledgement comment is not confirmation.
Count a condition confirmed only from a human-authored PR statement or a
response the user volunteers that unambiguously confirms it for the current
normalized trigger tuples. Never infer it from repository contents. New or
materially changed tuples need fresh confirmation.

Never pause, return `needs_input`, or prompt the user for these conditions.
The request travels with the review output — the prepared PR inline comment or
the local tracked checklist below — so the review always completes in one pass.

When readiness is unconfirmed in PR mode, set
`approval_status: pending_author_confirmation`. This is informational, not a
gate on the review: a verified Critical, High-risk defect still produces
`REQUEST_CHANGES`; otherwise a third-party PR uses `COMMENT` (approving while
asking the author to confirm deployment state would contradict the request),
and self-authored and unknown-ownership PR reviews return their ordinary code
verdict with the readiness comment attached.

When readiness is unconfirmed in local mode, return
`pre_stage_human_acknowledgement: tracked` and the complete checklist alongside the
ordinary `code_verdict: APPROVE | REQUEST_CHANGES`.

### PR mode

Build one `human_acknowledgement` for the entire PR:

- `required: true`
- `reasons`: the trigger categories that fired
- `anchors`: every relevant changed `path:line`
- `primary_anchor`: the most consequential changed line, preferring an
  irreversible migration, environment-variable change, feature-flag change,
  production-infra change, a modified existing test, then a newly added
  suppression
- `operational_confirmation`: `confirmed | pending_author | not_applicable`

Emit exactly one inline annotation at `primary_anchor`, titled
`Human acknowledgement requested`, and list the other anchors in its body so a reviewer
can jump directly to every relevant surface. Do not repeat the request in the
review body, another inline comment, a question, residual risk, or a lens
finding. Dedupe the annotation against existing comments by substance as well
as line, but never treat deduplication as operational confirmation.

The acknowledgement is independent of defect findings: a newly added
suppression (always a code smell), unsafe migration, or weakened test may also become a normal
verified finding, but the acknowledgement
itself bypasses finding verification and the Actionability Gate.

Use this prepared inline-comment shape, retaining only the sections whose
categories fired:

```markdown
Human acknowledgement requested: this PR changes surfaces that need deliberate
human acknowledgement. This is not an automatically identified defect or a
claim that the change is high-risk.

- `<path:line>` — <migration | environment-variable | feature-flag | config | infra/ops | lint/tooling suppression | modified existing test>
- `<path:line>` — <category>

Please reply to confirm:
- each changed environment variable has its appropriate value set in every
  staging and production environment;
- each changed feature flag has its appropriate value/configuration set in
  every staging and production environment; and
- each changed migration/backfill has been tested successfully in staging.

For any other listed config, infrastructure, or suppression anchors, please
verify the operational intent. For modified existing tests, acknowledge that
the expectation or coverage change is intentional and still protects the
desired outcome.
```

If all readiness tuples already have valid human confirmation, retain any
advisory acknowledgement anchors that still need attention, mark
`operational_confirmation: confirmed`, and do not ask for the readiness facts
again.

### Local pre-stage mode

Use stable key `review-handoff.operational-readiness` for readiness tuples and
`review-handoff.local-sensitive-changes` for advisory acknowledgement tuples.
Compare each set
with the matching workflow ledger's latest `accepted` scope and the wrapper's
invocation-local confirmed/accepted scopes.

Render one combined **Pending before PR or staging** checklist when either set
is uncovered. It is tracked output, not a question: list every uncovered
`category` and `path:line`, then the applicable facts someone must verify,
worded so it can be pasted into the eventual PR description or handoff:

> - [ ] Each listed environment variable and feature flag has its appropriate
>   value/configuration in every staging and production environment.
> - [ ] Each listed migration or backfill has been tested successfully in staging.
> - [ ] Listed config, infrastructure, and tooling-suppression changes match
>   their operational intent.
> - [ ] Edited existing tests' changed expectations or coverage are intentional
>   and still protect the desired outcome.

Do not repeat it per anchor or in Questions/residual risk. Auto/no-questions
mode cannot omit it. It never delays, re-dispatches, or changes the code
verdict.

- **Volunteered readiness confirmation:** when the user explicitly confirms the
  facts unprompted, the outer wrapper appends an `accepted` Finding Register row
  for `review-handoff.operational-readiness`, faithfully recording the confirmed
  facts, exact normalized readiness tuples, and review scope/base.
- **Volunteered advisory acknowledgement:** the wrapper may append the existing
  `accepted` row for `review-handoff.local-sensitive-changes`, covering only the
  advisory tuples.
- **No response, or a negative/incomplete one:** append nothing; the items stay
  on the tracked checklist.
- **No matching ledger:** honor a volunteered confirmation for this invocation
  only. Never create a workflow ledger; ledger creation remains owned by
  `my-workflow`.

On later passes, omit a checklist item only when every current normalized tuple is
covered by the latest matching `accepted` row or exact invocation-local scope.
A new category, path, or changed-content digest is new scope. Prior rows for
`review-handoff.local-sensitive-changes` never confirm operational readiness;
the separate key intentionally prevents older acknowledgements from unlocking
approval under this stronger contract.

## Author questions

Clarification needs follow the same rule: track them, never pause for them.
A `Severity: Question` finding, a verifier `requires clarification`, and any
walk-through candidate that is purely a request for author-only information
become author questions:

- **PR mode:** one prepared inline comment per question at its changed-line
  anchor, phrased to the author, naming the exact decision or information
  needed and, for `requires clarification`, the exact check to run. Dedupe
  against existing threads by substance.
- **Local mode:** list them in the output's Questions section in the same
  author-directed wording, so they can be carried into the PR.

An unanswered question never becomes `REQUEST_CHANGES` or `needs_input`.
