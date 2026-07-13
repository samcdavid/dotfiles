# Subagent Contract

Subagents should receive a bounded task, only the context needed for that task, and a compact output schema.

Rules:

- Do not pass whole plans or raw transcripts when a phase slice is enough.
- Ask subagents for evidence, paths, commands, and residual uncertainty.
- Treat subagent output as evidence, not authority; the orchestrator re-verifies important claims.
- Prefer summaries over raw output when returning to the main thread.

