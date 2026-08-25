# Protocol — implement-review

`implement-review` is the sole owner of the local implementation-to-clean-review
cycle. It reuses the existing implementation and review agents; it does not
reimplement their checklists or create a second repair loop.

## Route Selection and Preconditions

Read the available plan, behavior-first test strategy, base ref, and workflow
ledger before choosing work. Select exactly one route:

- **Plan delivery:** use only when an approved plan has unfinished behavioral
  phases and the ledger does not record the workflow or atomic delivery stage
  as complete. If that plan lacks an honest RED test or mechanical success
  criteria for an unfinished behavioral phase, return `blocked` rather than
  inventing a plan.
- **Review-first:** use when no plan is available, or when the supplied ledger
  marks the workflow or its `implement-review`/atomic delivery stage completed
  (including a recorded clean terminal result). The existing branch is the
  review subject; do not reopen completed planning or require a plan merely to
  examine and repair it.

Require a base ref for either route, deriving it by the shared review base-ref
rules when the caller did not supply one. Pass all available artifacts as review
context. An unavailable requirements source is recorded as such by `my-review`;
it does not prevent review-first from starting.

## Execution

1. On the plan-delivery route, dispatch `skill-my-implement` in embedded mode
   for every unfinished plan phase. Preserve its isolated executor and local-
   commit behavior. On the review-first route, do not dispatch implementation
   before the first review.
2. Run up to **five** review passes.
   - Plan delivery: each pass dispatches `skill-my-validate` in plan/embedded
     mode, then `skill-my-review` in local mode against the supplied base ref.
   - Review-first: pass 1 dispatches `skill-my-review` directly and records
     `validation: not_run`. If it is clean, exit clean without inventing a
     validation run. After a repair, each later pass dispatches
     `skill-my-validate` in session/embedded mode against the repair evidence,
     then `skill-my-review`.
   Record the validation result, review findings, and changed commits for every
   pass.
3. If validation blocks, or review returns a Critical finding, unresolved
   requirement, or substantive non-blocking finding, repair only those verified
   findings before another pass. For behavior changes, dispatch one
   `implementation-executor` per bounded finding with an honest RED test,
   explicit allowed paths, relevant plan constraints when available, and the
   verifier evidence. For review-first behavioral repairs, the verified finding
   supplies the bounded requirement; do not create a retrospective broad plan.
   For a genuinely non-behavioral edit, dispatch `quick-implement-agent` with
   the same evidence and bounded paths. Re-verify each repair and require its
   local commit before continuing.
4. Do not invoke `address-pr-feedback` local mode: it owns its own review loop
   and would create competing pass counts. It remains the workflow for external
   PR feedback.
5. Exit `clean` only after the terminal whole-branch `my-review` has no
   Critical, unresolved requirement, or substantive non-blocking finding. When
   the run made a repair, that review must follow a successful validation pass;
   the untouched review-first pass is the sole exception. Nits and clearly
   optional suggestions may be recorded as deferred, never silently erased.

## Stop Conditions

- `clean`: terminal validation and review are clean.
- `blocked`: an incomplete plan, impossible honest RED test, repeated repair
  failure, a required product decision, or validation failure outside safe local
  repair scope. Stop immediately with evidence.
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

The runner reports each phase commit as `locally_validated`, never as
`review_clean`. Only this terminal contract can set `review_clean: true`.

## Output Envelope

```markdown
status: clean | blocked | cap_reached
review_clean: true | false
route: plan_delivery | review_first
passes:
  - pass: <1-5>
    validation: not_run | pass | repaired | blocked
    findings: [<stable finding key>]
    repairs: [<commit SHA>]
surviving_findings: [<stable finding key>]
root_cause: <required unless clean>
external_action_requested: null | { actions, targets, rationale }
```
