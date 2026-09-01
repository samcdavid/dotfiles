---
model: sonnet
effort: high
name: my-implement
description: Execute approved implementation work sequentially by delegating each bounded edit task to Claude Haiku, then independently verifying and committing it.
---

# Implement Plan

This skill is the implementation orchestrator. Read [references/protocol.md](references/protocol.md) before executing work. Use `~/.claude/rules/verification-ladder.md` (or `~/.agents/rules/`) to select and record checks.

## Dispatch

Normalize the request into `{ mode, plan_path, artifact_inputs, ledger_path, stage, authority: local_only }` and execute its phases directly.

- For a standalone request, derive `plan_path` from `$ARGUMENTS`. If it is absent, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which approved plan to execute.
- For `/my-workflow`, the synchronized workflow ledger may be both `plan_path`
  and `ledger_path`; its `Implementation Plan`, `Test Strategy`, and
  `Architecture` sections are the approved execution inputs. Preserve supplied
  artifact inputs and execute in embedded mode. Return the stage outcome for
  `my-workflow` to record; do not claim workflow completion.
- Do not dispatch if the plan has no RED tests or success criteria for its next unfinished phase.

Delegate every edit task with `claude --model haiku --no-chrome --strict-mcp-config --dangerously-skip-permissions -p "<task to complete>"`. If that Haiku invocation cannot run, `codex --model gpt-5.6-luna exec "<task to complete>"` is an acceptable fallback. The delegate has all local permissions so it must perform the bounded edit rather than ask for approval; the task still limits it to its allowed paths and forbids remote actions. Keep tasks sequential and bounded; independently verify the resulting diff and checks before committing through `Skill(commit)`. Never infer authorization to push, publish, create or update a PR, or otherwise change a remote system.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return completed phases, commit SHAs, holistic verification evidence, deviations,
uncommitted or escalated work, the workflow-stage envelope when embedded, and
the recommended next command: `implement-review` only after every implementation
phase is complete. Name what each phase delivered and pair every SHA with its
subject/effect. Do not include raw Claude transcripts.
