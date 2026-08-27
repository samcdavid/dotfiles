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
or use `COMMENT`. This path is unavailable when requirements are missing or
partial, an existing unresolved thread concerns the changed lines, or any human
review trigger is present.

## Human-review triggers

In PR and local modes, scan added and modified diff lines for:

- database/schema/data migrations or backfills;
- new or changed environment-variable references, secrets/config lookups, or
  deployment-time settings;
- infrastructure and operations surfaces such as Terraform/Pulumi/CloudFormation,
  Kubernetes/Helm, deploy manifests, CI/CD workflows, service/resource limits,
  networking, permissions, feature-flag defaults, and production config;
- newly added linter, formatter, type-checker, or static-analysis ignores and
  suppressions, including file/config exclusions and inline disable comments.

These signals require judgment about deployment state, operational ownership,
or intentionally hidden diagnostics that repository analysis cannot settle.
They are handoff triggers, not automatic defects or blockers.

Normalize every trigger as `{ category, path, changed_content_digest }`, where
the digest covers the added/modified trigger content without its line number.
Sort and deduplicate these tuples. Line movement alone must not manufacture a
new trigger; new or materially changed trigger content must.

### PR mode

Build one `human_review_handoff` for the entire PR:

- `required: true`
- `reasons`: the trigger categories that fired
- `anchors`: every relevant changed `path:line`
- `primary_anchor`: the most consequential changed line, preferring an
  irreversible migration, production-infra change, env/config change, then a
  newly added suppression

Emit exactly one inline annotation at `primary_anchor`, titled
`Human review requested`, and list the other anchors in its body so a reviewer
can jump directly to every relevant surface. Do not repeat the request in the
review body, another inline comment, a question, residual risk, or a lens
finding. Dedupe it against existing comments by substance as well as line; if
an existing human-review request already covers the current anchors, emit none.

The handoff is independent of defect findings: a suspicious suppression or
unsafe migration may also become a normal verified finding, but the human-review
request itself bypasses finding verification and the Actionability Gate. It does
not by itself justify `REQUEST_CHANGES`.

Use this prepared inline-comment shape:

```markdown
Human review requested: this PR changes operationally owned or deliberately
suppressed surfaces that need repository-external judgment before merge.

- `<path:line>` — <migration | env/config | infra/ops | lint/tooling suppression>
- `<path:line>` — <category>

Please verify deployment/rollback assumptions and that each suppression is
intentional. This is a review handoff, not an automatically identified defect.
```

Keep only the categories that fired and do not add the same request to the
top-level review body.

### Local mode

Build one `local_human_confirmation` from every trigger not already covered by
the matching workflow ledger's latest accepted scope. Use the stable key
`review-handoff.local-sensitive-changes` and place this special confirmation as
review item/finding 1, before ordinary findings. It is a user decision, not a
defect claim: do not verifier-route it, send it through `/this-important`, or
let it independently produce `REQUEST_CHANGES`.

Ask exactly once for the current uncovered set:

> This local change set includes migration, environment/configuration,
> infrastructure/operations, or newly suppressed lint/tooling checks at the
> anchors below. Do you accept and acknowledge these review-sensitive changes
> and approve continuing this review/workflow without repeating this
> confirmation while these exact trigger contents remain unchanged?

List every uncovered `category` and `path:line` under the prompt. Do not ask once
per anchor or repeat the prompt in Questions/residual risk. Auto/no-questions
mode cannot waive this explicit confirmation.

- **Affirmative:** the outer wrapper appends one `accepted` Finding Register row
  using `finding-ledger.md`, recording the exact affirmative response, all
  current normalized trigger tuples, and the review scope/base. Continue the
  review and remove the confirmation from active findings.
- **Negative:** append nothing, stop with `needs_input: local human confirmation
  declined`, and preserve the anchors. Do not return APPROVE.
- **No matching ledger:** ask once for this invocation, but report that the
  acknowledgement cannot be durably suppressed. Never create a workflow ledger;
  ledger creation remains owned by `my-workflow`.

On later passes, suppress the confirmation when every current normalized trigger
tuple is covered by the latest `accepted` row for the stable key. A new category,
path, or changed-content digest is new scope: ask once for only the uncovered
set, then append a new row whose accepted scope covers the full current set.
