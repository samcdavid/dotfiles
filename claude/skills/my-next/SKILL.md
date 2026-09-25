---
name: my-next
description: Synthesize current session state into a prioritized action plan after research, validation, review, or divergent discussion.
disable-model-invocation: false
---

# Next

Clarify the path forward from current context.

## Load Rules

`~/.claude/rules/context-checkpoint.md`, `~/.claude/rules/question-policy.md`,
and `~/.claude/rules/human-readable-communication.md` are already loaded as
memory under Claude Code — apply them without re-reading. Under Codex, read
their `~/.agents/rules/` equivalents explicitly.

## Flow

1. Inventory verified facts, assumptions, artifacts, blockers, and open decisions.
2. Separate must-do from optional cleanup.
3. Prioritize next actions by unblock value and risk.
4. Recommend one immediate next step.

## Output

Return a concise ordered plan, decision points, and commands or skills to run next.
