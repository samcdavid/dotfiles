---
effort: high
name: my-implement
description: Execute approved implementation work sequentially in bounded phases, verifying and committing each one.
---

# Implement Plan

This skill is the sequential implementation coordinator. Read [references/protocol.md](references/protocol.md) before executing work. Apply `~/.claude/rules/verification-ladder.md` — already loaded as memory under Claude Code; read the `~/.agents/rules/` equivalent explicitly under Codex — to select and reuse checks.

## Dispatch

Normalize the request into `{ mode, plan_path, artifact_inputs, ledger_path, stage, authority: local_only }`. Dispatch one isolated worker per phase; retain coordination, independent verification, and commits here.

- For a standalone request, derive `plan_path` from `$ARGUMENTS`. If it is absent, list plans in `~/.thoughts/plans/` and ask the user which approved plan to execute.
- For `/my-workflow`, the synchronized workflow ledger may be both `plan_path`
  and `ledger_path`; its `Implementation Plan`, `Test Strategy`, and
  `Architecture` sections are the approved execution inputs. Preserve supplied
  artifact inputs and execute in embedded mode. Return the stage outcome for
  `my-workflow` to record; do not claim workflow completion.
- Do not dispatch if the plan has no RED tests or success criteria for its next unfinished phase.

Give a worker only its phase contract, relevant code/test excerpts, and the project instructions it needs. Keep phases sequential and bounded; independently verify the resulting diff and uncovered checks before committing through `Skill(commit)`. After each phase is committed, stop and report it, then wait for the caller to confirm before dispatching the next phase's worker — do not chain phases in one turn, including in embedded `my-workflow` mode. Do not invoke `implement-review` between phases: phase verification is sufficient until the plan is complete. Never infer authorization to push, publish, create or update a PR, or otherwise change a remote system.

## Present

Apply `~/.claude/rules/human-readable-communication.md` — already loaded as memory under Claude Code; read the `~/.agents/rules/` equivalent explicitly under Codex.
After each phase, return that phase's outcome, commit SHA/subject, verification
evidence, and any deviations, then stop and wait for the caller to say whether
to continue — never dispatch the next phase's worker in the same turn. Once
every phase is complete, return the holistic verification evidence, deviations,
uncommitted or escalated work, the workflow-stage envelope when embedded, and
the recommended next command: for an embedded `my-workflow` run, `my-validate`
exactly once after every implementation phase and the holistic verification gate
are complete; otherwise `implement-review` exactly once after those conditions.
On every 10th standalone phase's pause, also recommend a `/clear` before
resuming `my-implement` on the same plan. Name what each phase delivered and
pair every SHA with its subject/effect. Do not include raw implementation
transcripts.
