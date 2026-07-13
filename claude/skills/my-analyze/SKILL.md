---
model: opus
name: my-analyze
description: Compare research, specs, plans, and related artifacts to find contradictions, coverage gaps, scope drift, and implementation-readiness risks.
---

# Analyze

Audit consistency across artifacts before implementation. This is not a code review; it checks whether the written plan still matches the research, spec, decisions, and constraints.

## Load Rules

Read:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`

Use `~/.agents/rules/` when running through Codex. For complex multi-artifact comparisons or workflow-stage runs, read `references/protocol-index.md`.

## Flow

1. Resolve artifacts from `$ARGUMENTS`, workflow ledger, or recent research/spec/plan directories.
2. Require at least two artifacts; if only one exists, recommend `my-clarify`.
3. Read artifacts fully and ledger decisions.
4. Compare:
   - research findings vs spec claims
   - spec acceptance criteria vs plan phases
   - non-goals vs proposed implementation
   - risks vs validation strategy
   - assumptions vs unresolved decisions
5. Classify gaps as blocking, important, or minor.
6. Save report when appropriate and append path to workflow ledger.

## Output

Return consistency findings with artifact references, why each matters, recommended fix, and whether implementation should proceed.

