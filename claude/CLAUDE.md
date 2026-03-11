# Global Principles

These apply to all work across all projects.

## Constraints Over Instructions

Define boundaries, not checklists. When given a task, think about what SHOULD NOT happen rather than enumerating every step. Agents fixate on instruction lists while ignoring context — constraints channel effort more effectively.

## Two-Translation Verification

Before making significant changes, translate the user's intent back to them:
> "Here's what I understand you want and the assumptions I'm making — confirm before I proceed."

After making changes, translate the code back to plain language and compare against original intent. Gaps between intent and implementation become visible through this loop.

## Trust Debt

Every assumption accepted without verification is debt. Flag assumptions explicitly rather than silently embedding them in code. When uncertain about intent, behavior, or correctness — verify against actual code, don't guess from memory.

## Compounding Codification

When you learn something useful during a session (a pattern, a gotcha, a convention), suggest persisting it — update CLAUDE.md, project docs, or relevant configuration. Knowledge that only lives in conversation history is lost.

## Throughput Over Perfection

Tolerate small non-blocking issues. Batch quality passes rather than blocking progress on every minor concern. Distinguish between "this will cause a bug" and "this could be slightly better" — only block on the former.

## Separate Implementer from Reviewer

The one reviewing should not be the one who wrote the code. When reviewing your own work (via /harness:validate or /harness:review), approach it as a skeptical outsider. Re-read the code fresh — do not rely on what you "remember" writing.
