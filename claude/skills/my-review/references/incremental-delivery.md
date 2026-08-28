# Incremental Delivery Scope

Use this during triage and pass the resolved scope to the requirements reviewer.
The linked issue describes the eventual destination; it does not automatically
make every final-feature requirement a condition of merging this change.

## Resolve the promised increment

Build `delivery_increment` from the strongest available evidence, in this order:

1. explicit review scope supplied by the user;
2. the PR title and description;
3. completed or currently reviewed phases in the living workflow ledger;
4. issue comments that define a staged delivery or handoff;
5. commit messages that explicitly record the increment.

Do not infer an incremental scope merely because the diff is incomplete. If the
evidence is contradictory or too vague to tell what this change promises,
surface one human-readable scope question before deciding requirements coverage.

Record:

```yaml
delivery_increment:
  summary: "The concrete outcome this change promises now"
  evidence: "PR description, ledger section, user statement, or issue comment"
  included_outcomes: []
  foundation_surfaces: []
  deferred_outcomes:
    - outcome: "What remains for a later increment or integration"
      next_step_or_owner: "Known next step, teammate, or team when available"
      evidence: "Where the deferral or handoff is stated"
  user_visible_now: true | false
```

Classify each eventual-feature requirement as:

- **Included now** — promised by this increment and subject to normal coverage
  review.
- **Foundation for later integration** — internal code or a supporting surface
  intentionally shipped now so later work can build on or integrate it.
- **Deferred to a later increment** — explicitly outside this change's promise.
- **Unclear** — the available evidence does not establish whether it belongs in
  this increment.

## Approval rule

A partial or non-user-facing increment is eligible for approval when:

- every included outcome is complete and verified at the appropriate boundary;
- the change is safe to build, deploy, and migrate;
- it does not leave reachable behavior broken;
- any public, API, persistence, or cross-service surface exposed now is coherent
  and compatible for its current consumers;
- no present regression, security, privacy, or data-integrity defect survives;
  and
- the deferred integration or handoff is described accurately enough that the
  review does not imply the eventual feature is complete.

A separate follow-up ticket is useful evidence but is not required. A PR
description, workflow ledger, issue comment, explicit next step, or named
person/team can establish a legitimate staged delivery.

Do not raise a finding merely because the eventual feature is not user-facing,
not fully integrated, or not complete in this PR. Raise a finding when:

- the change claims an outcome that it does not deliver;
- omitted work is required for the current increment to compile, run, deploy,
  migrate, or behave safely;
- a partially exposed boundary is internally inconsistent or incompatible;
- a reachable path is broken; or
- a claimed deferral disguises a present regression, security/privacy risk, or
  data-integrity problem.

When the increment is consequentially unclear, request the missing scope
decision in plain language. Do not silently assume either full-feature delivery
or valid incremental delivery.
