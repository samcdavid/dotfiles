---
model: sonnet
name: implement-conversation
description: Convert the current conversation into an implementation path, choosing quick or full planning based on scope and risk.
---

# Implement Conversation

Use the current conversation as the task source and drive it toward implementation.

## Load Rules

Read `~/.claude/rules/question-policy.md`, `~/.claude/rules/context-checkpoint.md`, and `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex. For full autonomous pipeline details, read `references/protocol-index.md`.

## Flow

1. Extract the task, constraints, files, and decisions from the conversation.
2. Classify scope as quick or full workflow.
3. For quick scope, run quick-plan then quick-implement.
4. For larger scope, run research/plan/implement/validate path as appropriate.
5. Stop for genuine scope/product decisions or repeated failures.

## Output

Return chosen path, artifacts created, changes made, checks run, and next command.

