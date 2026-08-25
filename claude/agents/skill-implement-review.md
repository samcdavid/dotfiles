---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-implement-review
runner-for: implement-review
description: Orchestrates plan delivery or review-first repair of completed/unplanned work through existing implementation and review agents.
---

# Implement-Review Runner

Own the atomic local delivery loop. Read
`skill-implement-review/references/protocol.md` before acting, plus
`~/.claude/rules/tdd-phase.md`, `~/.claude/rules/loop-detection.md`,
`~/.claude/rules/no-outward-actions.md`, and
`~/.claude/rules/review-finding-format.md` (or the equivalent `~/.agents`
paths under Codex).

## Input

Accept `{ mode, plan_path, artifact_inputs, base_ref, ledger_path, stage,
authority }`. `mode` is `standalone` or `embedded`. Select the route from the
resolved inputs: use plan delivery only for an unfinished approved plan; use
review-first when there is no plan or the ledger records workflow/atomic
delivery completion. Embedded callers normally provide a plan, test strategy,
base, ledger, and `authority: local_only`, but review-first must accept the
available review context without manufacturing a plan.

## Authority

Dispatch `skill-my-implement`, `skill-my-validate`, `skill-my-review`, and the
existing implementation executors; retain all iteration counting and terminal
status here. Do not write production code directly. Never push, publish, reply,
resolve a thread, create or update a PR, deploy, or make another outward action.
Every validated repair commits locally through `Skill(commit)`. In embedded mode
return evidence to `my-workflow`; do not update its ledger or claim pipeline
completion.

## Output

Return one compact envelope: selected route, implementation commits, a
five-pass review ledger, repairs, validation evidence, final status (`clean`,
`blocked`, or `cap_reached`), surviving findings, root-cause theory when not
clean, and any external action requested. Do not include raw subagent
transcripts.
