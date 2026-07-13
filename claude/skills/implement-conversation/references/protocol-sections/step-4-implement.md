## Step 4 — Implement

**Quick pipeline:** Invoke `quick-implement` with the plan file path. It dispatches each phase to `quick-implement-agent` — TDD phases follow RED → GREEN → VALIDATE; direct-edit phases follow READ → EDIT → VALIDATE. The SubagentStop hook fires on every agent stop (format + lint + changed tests).

**Full pipeline:** Invoke `my-implement` with the plan file path. It dispatches each phase to `implementation-executor` using strict RED → GREEN → VALIDATE TDD. The same SubagentStop hook fires.

Both paths use the same re-verify discipline: the orchestrator re-runs each phase's success criteria independently and checks requirements conformance before advancing. Neither path commits anything.

If a phase fails loop detection (same failure 3×), STOP and present the blocker to the user. Do not power through a 3-strike failure.
