# Protocol — my-implement

`my-implement` owns sequential local implementation. It gives each bounded
phase to one isolated worker, then verifies the result and controls retries and
commits. Workers never share a working tree concurrently.

## Inputs and gates

Read the plan index, the next unfinished phase, and only the test-strategy and
architecture material that constrains that phase. Keep the whole-plan success
criteria for completion. In embedded workflow mode, the `Implementation Plan`,
`Test Strategy`, and `Architecture` sections have those roles. Refuse to execute
a behavioral phase without an honest RED test, matching behavioral contract,
allowed paths, and mechanical success criteria. Split a phase that contains more
than one small behavior.

`address-pr-feedback` and `implement-review` may invoke this skill for one
already-triaged repair. They provide the same bounded slice directly; a plan file
is not required for that repair mode. A behavioral repair needs RED and GREEN
requirements. A genuinely non-behavioral repair is `direct_edit` and must not
invent a test.

`my-quick`, `ci-babysit`, `update-deps`, and `my-validate` may likewise supply
one approved bounded slice. `autoresearch` may use `commit_policy: defer` for a
single reversible experiment; after this skill verifies the edit, autoresearch
alone compares its metric and either commits the kept experiment or discards it.

Read the project's instructions and `no-outward-actions.md`. Read
`tdd-phase.md` only for behavioral work and `loop-detection.md` only after a
failure. Read `gotchas.md` only for an Elixir phase that touches the database.
The plan supplies verification commands; consult
`references/verification-commands.md` only when a valid plan omits a command
and project instructions do not provide one.

## Phase loop

For each phase, in order:

1. Build a phase contract containing only the phase name and desired outcome,
   TDD/direct-edit classification, RED tests when behavioral, GREEN changes,
   behavioral test contracts, allowed paths, relevant architecture constraints,
   verification commands, explicit success criteria, and minimal relevant
   code/test excerpts. Do not include earlier phases or unrelated plan sections.
2. Run one worker with that contract. It may change only `allowed_paths`, must
   use RED → GREEN → VALIDATE for behavioral work, and must not push or make
   remote changes. Local edits to those paths are authorized. It returns compact
   evidence: commands, exit status, changed files, deviations, and readiness.
   Truncate failure output to the diagnostic tail; do not return passing logs.
   Invoke it with the serialized contract:

   ```bash
   codex --model gpt-5.6-terra exec "<phase contract>"
   ```

   If that worker cannot run, perform the same bounded phase directly. Never
   delegate implementation to Haiku. Run exactly one worker at a time.
3. Independently inspect the changed diff and evidence. Confirm scope, outcome,
   and behavior-focused tests. Re-run only a success criterion without current
   evidence after the last relevant edit; otherwise reuse the recorded command,
   commit, covered paths, and result. Record that evidence for callers.
4. If verification passes, invoke `Skill(commit)` scoped to the phase's paths,
   mark the phase done, and advance. With `commit_policy: defer`, return the
   verified bounded diff uncommitted to `autoresearch` for its metric decision.
   Never commit failed or escalated work.

Do not invoke `implement-review` after an individual phase. The independent
phase verification above is the required per-phase quality gate. Invoke
`implement-review` once only after every phase has passed and the holistic
validation below completes. In embedded `my-workflow` mode, return to the
workflow instead: it runs one whole-plan `my-validate` gate before invoking
`implement-review`.

## Retries and deviations

On a first failure, tighten the contract with the observed gap and dispatch one
replacement worker without widening the phase's path or no-remote constraints.
Treat any repeat root failure
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
