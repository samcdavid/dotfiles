---
model: sonnet
name: quick-implement
description: Execute a quick-plan phase by phase. Dispatches TDD phases to quick-implement-agent using RED → GREEN → VALIDATE; dispatches direct-edit phases to quick-implement-agent for targeted function-level edits. Owns loop detection. Uses the same format/lint/test SubagentStop hook as my-implement.
---

# Quick Implement

Execute a `quick-plan` file phase by phase, dispatching each to a fresh `quick-implement-agent`. This is the lighter counterpart to `my-implement` — same orchestration discipline (one agent at a time, independent re-verify, loop detection), but handles both TDD phases and direct-edit phases.

Why this shape: each phase runs in a small, fresh context. The orchestrator re-verifies independently (the implementer is never its own reviewer), and the SubagentStop hook runs format + lint + changed tests automatically on every agent stop.
