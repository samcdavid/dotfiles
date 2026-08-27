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

## PR-only human-review triggers

In PR mode, scan added and modified diff lines for:

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
