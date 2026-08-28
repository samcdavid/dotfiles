# Change-Set Risk and Human Review Handoff

Load during triage, before reviewer fan-out. This classifies the aggregate set of
changes, not individual findings. Finding `Risk` in `finding-axes.md` remains a
separate likelihood-and-blast-radius score.

## Overall change-set risk

Record `overall_change_risk: Low | Medium | High` with one diff-grounded
rationale.

- **Low** — the aggregate diff is small, local, reversible, and does not alter
  runtime behavior, public or persistence contracts, data, authorization,
  dependencies, deployment/configuration, infrastructure, or requirements. No
  human-review trigger below is present and no source gap or ambiguity could
  change that classification. Typical examples are documentation, comments,
  snapshots/fixtures that mirror an already-reviewed behavior, or a mechanical
  refactor whose equivalence is directly visible.
- **Medium** — the diff changes behavior or operational shape in a contained,
  reversible way, or needs a human-review handoff, but has no evident wide or
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
rationale. Do not fan out research/lens/verifier agents, manufacture suggestions,
or use `COMMENT`. This path is unavailable when requirements included in the
declared delivery increment are missing or partial, when the increment is
consequentially unclear, an existing unresolved thread concerns the changed
lines, or any human review trigger is present. Requirements explicitly deferred
from this increment do not disable the fast path by themselves.

## Human-review triggers

Scan added and modified diff lines in PR and local modes. Build two disjoint
trigger sets.

`operational_readiness_triggers` require explicit human confirmation before an
approval is eligible:

- database/schema/data migrations or backfills;
- new or changed runtime environment-variable references, declarations, or
  deployment values; and
- new or changed feature-flag definitions, lookups, defaults, rollout values,
  or targeting configuration.

`advisory_handoff_triggers` still require human attention, but do not by
themselves withhold approval:

- other secrets/config lookups or deployment-time settings not already captured
  as environment variables or feature flags;
- infrastructure and operations surfaces such as Terraform/Pulumi/CloudFormation,
  Kubernetes/Helm, deploy manifests, CI/CD workflows, service/resource limits,
  networking, permissions, and production config; and
- newly added linter, formatter, type-checker, or static-analysis ignores and
  suppressions, including file/config exclusions and inline disable comments.

These signals require repository-external knowledge. They are not automatic
defects, do not acquire finding severity or risk, and do not independently
justify `REQUEST_CHANGES`. The operational-readiness set withholds approval
because the agent cannot verify deployment state or staging execution, not
because the diff is presumed unusually risky.

Normalize every trigger as `{ category, path, changed_content_digest }`, where
`category` is `migration`, `environment-variable`, `feature-flag`, `config`,
`infra-ops`, or `lint-tooling-suppression`, and the digest covers the
added/modified trigger content without its line number. Sort and deduplicate
these tuples. Line movement alone must not manufacture a new trigger; new or
materially changed trigger content must.

## Operational readiness clearing condition

Approval remains pending until a human explicitly confirms every applicable
condition:

- **Environment variables:** the appropriate value has been set in every
  staging and production environment.
- **Feature flags:** the appropriate flag value/configuration has been set in
  every staging and production environment.
- **Migrations/backfills:** the changed migration or backfill has been tested
  successfully in staging.

A generic acknowledgement, request to continue, prior approval, passing local
tests, or the existence/deduplication of a handoff comment is not confirmation.
Accept a direct user response or a human-authored PR statement only when it
unambiguously confirms the applicable condition for the current normalized
trigger tuples. Never infer it from repository contents. New or materially
changed tuples require fresh confirmation.

When readiness confirmation is missing, complete the substantive review but
return `status: needs_input`, `approval_status: pending_human_confirmation`, and
no `APPROVE` verdict. A verified Critical, High-risk defect may still produce
`REQUEST_CHANGES`; otherwise a third-party PR may use `COMMENT`, while local,
self-authored, and unknown-ownership reviews remain pending without a verdict.
After explicit confirmation, re-dispatch with the exact confirmed tuples and
compute the ordinary relationship-constrained verdict.

### PR mode

Build one `human_review_handoff` for the entire PR:

- `required: true`
- `reasons`: the trigger categories that fired
- `anchors`: every relevant changed `path:line`
- `primary_anchor`: the most consequential changed line, preferring an
  irreversible migration, environment-variable change, feature-flag change,
  production-infra change, then a newly added suppression
- `operational_confirmation`: `confirmed | required | not_applicable`

Emit exactly one inline annotation at `primary_anchor`, titled
`Human review requested`, and list the other anchors in its body so a reviewer
can jump directly to every relevant surface. Do not repeat the request in the
review body, another inline comment, a question, residual risk, or a lens
finding. Dedupe the annotation against existing comments by substance as well
as line, but never treat deduplication as operational confirmation.

The handoff is independent of defect findings: a suspicious suppression or
unsafe migration may also become a normal verified finding, but the handoff
itself bypasses finding verification and the Actionability Gate.

Use this prepared inline-comment shape, retaining only the sections whose
categories fired:

```markdown
Human review requested: this PR changes operationally owned surfaces that need
repository-external confirmation. This is a readiness check, not an
automatically identified defect or a claim that the change is high-risk.

- `<path:line>` — <migration | environment-variable | feature-flag | config | infra/ops | lint/tooling suppression>
- `<path:line>` — <category>

Before approval, please explicitly confirm:
- each changed environment variable has its appropriate value set in every
  staging and production environment;
- each changed feature flag has its appropriate value/configuration set in
  every staging and production environment; and
- each changed migration/backfill has been tested successfully in staging.

For any other listed config, infrastructure, or suppression anchors, please
verify the operational intent. Approval remains pending only for the applicable
environment-variable, feature-flag, and migration confirmations above.
```

If all readiness tuples already have valid human confirmation, retain any
advisory handoff anchors that still need review, mark
`operational_confirmation: confirmed`, and do not ask for the readiness facts
again.

### Local mode

Use stable key `review-handoff.operational-readiness` for readiness tuples and
`review-handoff.local-sensitive-changes` for advisory tuples. Compare each set
with the matching workflow ledger's latest `accepted` scope and the wrapper's
invocation-local confirmed/accepted scopes.

Present one combined first review item when either set is uncovered. List every
uncovered `category` and `path:line`, then ask only for the applicable facts:

> This local change set includes operationally owned changes that require human
> review. For every listed environment variable and feature flag, confirm that
> its appropriate value/configuration has been set in every staging and
> production environment. For every listed migration or backfill, confirm that
> it has been tested successfully in staging. Please also acknowledge any other
> listed config, infrastructure, or tooling-suppression changes. These checks do
> not imply that the change is unusually risky, but approval remains pending
> until the environment-variable, feature-flag, and migration conditions are
> explicitly confirmed.

Do not ask once per anchor or repeat the prompt in Questions/residual risk.
Auto/no-questions mode cannot waive it. Continue the substantive review so the
user receives all code findings in the same pass, but return `needs_input` and
withhold approval while any readiness tuple is unconfirmed.

- **Explicit readiness confirmation:** the outer wrapper appends an `accepted`
  Finding Register row for `review-handoff.operational-readiness`, faithfully
  recording the confirmed facts, exact normalized readiness tuples, and review
  scope/base. Re-dispatch with those tuples as confirmed scope.
- **Explicit advisory acknowledgement:** the wrapper may append the existing
  `accepted` row for `review-handoff.local-sensitive-changes`, covering only the
  advisory tuples.
- **Negative or incomplete response:** append nothing for the unconfirmed set;
  preserve the anchors and return `needs_input`. Do not return `APPROVE`.
- **No matching ledger:** accept the facts for this invocation, but report that
  they cannot be durably reused. Never create a workflow ledger; ledger creation
  remains owned by `my-workflow`.

On later passes, suppress a prompt only when every current normalized tuple is
covered by the latest matching `accepted` row or exact invocation-local scope.
A new category, path, or changed-content digest is new scope. Prior rows for
`review-handoff.local-sensitive-changes` never confirm operational readiness;
the separate key intentionally prevents older acknowledgements from unlocking
approval under this stronger contract.
