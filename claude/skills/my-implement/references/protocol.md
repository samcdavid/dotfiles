# Protocol — my-implement

`my-implement` owns sequential local implementation. It performs each bounded
phase itself, then verifies the result and controls retries and commits.

## Inputs and gates

Read the approved plan completely. In embedded workflow mode, use its
`Implementation Plan` as phases, `Test Strategy` as the binding test contract,
and `Architecture` as constraints. Refuse to execute a behavioral phase without
an honest RED test, matching behavioral contract, allowed paths, and mechanical
success criteria. Split a phase that contains more than one small behavior.

`address-pr-feedback` and `implement-review` may invoke this skill for one
already-triaged repair. They provide the same bounded slice directly; a plan file
is not required for that repair mode. A behavioral repair needs RED and GREEN
requirements. A genuinely non-behavioral repair is `direct_edit` and must not
invent a test.

`my-quick`, `ci-babysit`, `update-deps`, and `my-validate` may likewise supply
one approved bounded slice. `autoresearch` may use `commit_policy: defer` for a
single reversible experiment; after this skill verifies the edit, autoresearch
alone compares its metric and either commits the kept experiment or discards it.

Read the project's instructions, `tdd-phase.md`, `loop-detection.md`,
`no-outward-actions.md`, this skill's `gotchas.md`, and
`references/verification-commands.md` when relevant.

## Phase loop

For each phase, in order:

1. Assemble a minimal task containing the phase name and desired outcome,
   TDD/direct-edit classification, RED tests when behavioral, GREEN changes,
   behavioral test contracts, allowed paths, architectural constraints,
   verification commands, and explicit success criteria.
2. Perform the phase yourself. Change only `allowed_paths`; use RED → GREEN →
   VALIDATE for behavioral work; do not push or make remote changes. Record
   commands, changed files, validation outcomes, deviations, and whether the
   work is ready to commit. Local edits to those paths are already authorized.
3. Independently read the diff and rerun every success criterion. Confirm the
   result stays in bounds, delivers the requested outcome, and that behavioral
   tests assert outcomes rather than implementation details.
4. If verification passes, invoke `Skill(commit)` scoped to the phase's paths,
   mark the phase done, and advance. With `commit_policy: defer`, return the
   verified bounded diff uncommitted to `autoresearch` for its metric decision.
   Never commit failed or escalated work.

Do not invoke `implement-review` after an individual phase. The independent
phase verification above is the required per-phase quality gate. Invoke
`implement-review` once, after every phase has passed and the holistic
validation below completes.

## Retries and deviations

On a first failure, correct the observed gap and retry once without widening the
phase's path or no-remote constraints. Treat any repeat root failure
as an escalation and report
the goal, evidence, attempts, root-cause theory, and proposed next step. If the
phase needs paths outside its scope, a changed API, or a design decision, stop
for a major deviation. Minor adaptations may continue when recorded.

## Completion

After all phases pass, run the plan's holistic validation, update the plan or
ledger status as appropriate, and return phase behavior, commit SHA/subject,
verification evidence, deviations, and any unresolved work. In embedded mode,
return evidence to `my-workflow` without updating its ledger or claiming the
pipeline is complete.
