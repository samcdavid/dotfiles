---
model: sonnet
name: publish-review
description: Publish prepared PR review to GitHub inline comments, thread replies, review body via gh api.
---

# Publish Review

Publish already prepared and verified review comments.

## Load Rules

Read `~/.claude/rules/pr-mode-readonly.md`, `~/.claude/rules/pr-cost-control.md`, `~/.claude/rules/review-finding-format.md`, `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex.

For GitHub API mapping details, read `references/protocol.md`.

## Flow

1. Confirm user explicitly wants review published.
2. Identify PR, head SHA, diff positions, existing threads, prepared comments.
3. Map each finding to correct inline location or thread reply.
4. Validate comments deduped, actionable, not already posted.
5. Publish via `gh api`.

## Output

Return posted review summary, inline comment count, thread replies, and any comments skipped with reasons.
