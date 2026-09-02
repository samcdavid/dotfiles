# Protocol — implement-review

`implement-review` is the sole owner of the local post-implementation
review-to-clean cycle. Initial plan execution belongs to `my-implement` and must
finish before this loop starts. This runner reuses validation, review, and repair
agents; it does not reimplement their checklists or create a second repair loop.

## Preconditions

Read the available plan, behavior-first test strategy, base ref, workflow ledger,
and implementation evidence before starting.

- For an embedded workflow plan, require every phase/checklist item complete,
  plan status `implemented`, the successful holistic test gate from
  `my-implement`, and a passing whole-plan `my-validate` outcome. If
  implementation evidence is missing or any phase remains unfinished, return
  `blocked` with the exact `my-implement` handoff. If the validation outcome is
  missing or non-passing, return `blocked` with the exact `my-validate` handoff.
  Do not run either prerequisite, start a review pass, or spend loop budget.
- When no plan is supplied, treat the existing branch as unplanned completed
  work and review it directly. Do not manufacture a retrospective plan.

Require a base ref for planned or unplanned work, deriving it by the shared
review base-ref rules when the caller did not supply one. Pass all available
artifacts as review context. An unavailable requirements source is recorded as
such by `my-review`;
it does not prevent review from starting.

## Execution

1. Start the loop only after the preconditions above pass. Pass 1 dispatches
   `skill-my-review` directly and records the completed whole-plan validation
   outcome as `validation: whole_plan_gate` (or `implementation_gate` for
   standalone planned work, or `not_run` for unplanned existing work). If it is
   clean, exit without inventing another validation run.
2. Run up to **five** review passes. After a repair, each later pass dispatches
   `skill-my-validate` in session/embedded mode against the repair evidence,
   then `skill-my-review`.
   Record the validation result, review findings, and changed commits for every
   pass.
3. If validation blocks, or review returns a Critical finding, unresolved
   requirement, or substantive non-blocking finding, repair only those verified
   findings before another pass. For behavior changes, dispatch one
   `my-implement` per bounded finding with an honest RED test, explicit allowed
   paths, relevant plan constraints when available, and verifier evidence. For
   unplanned-work behavioral repairs, the verified finding supplies the bounded
   requirement; do not create a retrospective broad plan. For a genuinely
   non-behavioral edit, invoke `my-implement` in direct-edit repair mode with
   the same evidence and bounded paths. Re-verify each repair and require its
   local commit before continuing.
4. Do not invoke `address-pr-feedback` local mode: it owns its own review loop
   and would create competing pass counts. It remains the workflow for external
   PR feedback.
5. Exit `clean` only after the terminal whole-branch `my-review` has no
   Critical, unresolved requirement, or substantive non-blocking finding. When
   the run made a repair, that review must follow a successful validation pass;
   the untouched first review pass is the sole exception. Nits and clearly
   optional suggestions may be recorded as deferred, never silently erased.

## Stop Conditions

- `clean`: the terminal review is clean, and validation passed after the latest
  repair when any repair occurred. Any environment-variable, feature-flag, or
  migration operational-readiness gate is explicitly confirmed.
- `blocked`: an incomplete plan, impossible honest RED test, repeated repair
  failure, a required product decision, an unconfirmed operational-readiness
  gate, or validation failure outside safe local repair scope. Stop immediately
  with evidence; readiness is a human handoff, not a repair finding.
- `cap_reached`: the fifth review pass still has substantive findings. Do not
  call it complete, do not start a sixth pass, and report each pass's finding
  delta, commits, and root-cause theory.

## Review Evidence Contract

Pass the plan, test strategy, base ref, changed-file manifest, and ledger to
`skill-my-review`. A review pass is accepted only if its envelope states:

- the complete branch range and active-lens manifest;
- the requirements source (including an issue inferred from the branch where
  applicable), or a concrete reason it is unavailable;
- final duplicate detection against both current review-thread and review-comment
  indexes in PR mode;
- a changed-line causal proof for every Critical finding; and
- any earlier finding reopened because a repair touched its causal path.
- `approval_status: eligible`; `pending_human_confirmation` can never set
  `review_clean: true` even when there are no code findings.

Supplied implementation phase commits remain `locally_validated`, never
`review_clean`. Only this terminal contract can set `review_clean: true`.

## Output Envelope

```markdown
status: clean | blocked | cap_reached
review_clean: true | false
route: review_repair
passes:
  - pass: <1-5>
    validation: implementation_gate | not_run | pass | repaired | blocked
    findings: [{ key: <stable key>, problem: <what is wrong>, fix: <required action> }]
    repairs: [{ sha: <commit SHA>, subject: <commit subject>, effect: <what changed> }]
surviving_findings: [{ key: <stable key>, problem: <what remains>, fix: <next action> }]
root_cause: <required unless clean>
external_action_requested: null | { actions, targets, rationale }
```
