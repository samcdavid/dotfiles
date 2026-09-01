# Protocol — my-implement

`my-implement` owns sequential local implementation. It does not edit production
code or tests itself: each bounded phase is delegated to Claude Haiku, then the
orchestrator independently verifies the result and controls retries and commits.

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

Read the project's instructions, `tdd-phase.md`, `loop-detection.md`,
`no-outward-actions.md`, this skill's `gotchas.md`, and
`references/verification-commands.md` when relevant.

## Phase loop

For each phase, in order:

1. Assemble a minimal task containing the phase name and desired outcome,
   TDD/direct-edit classification, RED tests when behavioral, GREEN changes,
   behavioral test contracts, allowed paths, architectural constraints,
   verification commands, and explicit success criteria.
2. Tell the delegate it may change only `allowed_paths`; it must use RED → GREEN
   → VALIDATE for behavioral work, must not push or make remote changes, and must
   return commands, changed files, validation outcomes, deviations, and whether
   the work is ready to commit. Invoke it exactly as:

   ```bash
   claude --model haiku --no-chrome --strict-mcp-config -p "<task to complete>"
   ```

   Escape or otherwise safely serialize task contents before invoking the shell.
   Run exactly one delegate at a time because phases share a working tree.
3. Independently read the diff and rerun every success criterion. Confirm the
   result stays in bounds, delivers the requested outcome, and that behavioral
   tests assert outcomes rather than implementation details.
4. If verification passes, invoke `Skill(commit)` scoped to the phase's paths,
   mark the phase done, and advance. Never commit failed or escalated work.

## Retries and deviations

On a first failure, tighten the task with the observed gap and delegate once
more. If the same root failure survives the second attempt, stop and report the
goal, evidence, attempts, root-cause theory, and a proposed next step. If the
phase needs paths outside its scope, a changed API, or a design decision, stop
for a major deviation. Minor adaptations may continue when recorded.

## Completion

After all phases pass, run the plan's holistic validation, update the plan or
ledger status as appropriate, and return phase behavior, commit SHA/subject,
verification evidence, deviations, and any unresolved work. In embedded mode,
return evidence to `my-workflow` without updating its ledger or claiming the
pipeline is complete.
