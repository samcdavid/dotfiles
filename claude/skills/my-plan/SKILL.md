---
model: opus
name: my-plan
description: Create a detailed implementation plan with mechanically verifiable success criteria, phase boundaries, tests-first steps, and explicit non-goals.
---

# Create Plan

Turn approved research/spec context into an implementation plan that `my-implement` can execute phase by phase.

## Load Rules

Read:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/tdd-phase.md`

Use `~/.agents/rules/` when running through Codex. For complex plans, workflow resumes, or ambiguous scope decisions, read `references/protocol-index.md`.

## Flow

1. Resolve task from `$ARGUMENTS`, conversation, workflow ledger, research, spec, ticket, or file path.
2. Read existing workflow ledger if present; consume linked research/spec artifacts before asking questions.
3. Research factual gaps yourself. Pause only for genuine scope, product, or approach decisions.
4. Propose implementation approach and boundaries.
5. Write ordered phases, each small enough for one executor run.
6. For every behavioral phase include RED tests, GREEN changes, allowed paths, verification commands, and success criteria.
7. State non-goals and risks explicitly.
8. Save plan under `~/.claude/thoughts/shared/plans/`.
9. Append plan path and assumptions/decisions to workflow ledger when present.

## Plan Quality Bar

- Mechanical success criteria, not prose-only “done.”
- One behavior or small unit per phase.
- Tests first for behavioral changes.
- Explicit allowed paths and architectural constraints.
- Clear “what we are not doing.”

## Output

Return the plan path, phase summary, decision points, assumptions, and recommended next command.

