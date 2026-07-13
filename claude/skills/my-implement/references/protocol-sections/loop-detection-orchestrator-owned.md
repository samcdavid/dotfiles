## Loop Detection (orchestrator-owned)

The executor stops itself after one repeated failure; **you** track failures across attempts. For a given phase:

- **First failure** (criterion fails or executor escalates): diagnose from the report + the diff. If the cause is a too-thin brief (missing path, ambiguous criterion), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total across executor + your re-runs): **STOP.** Do not re-dispatch again. Present to the user:
  - What this phase is trying to accomplish
  - What keeps failing + the error output
  - What the executor and you have tried
  - Your best root-cause theory
  - Suggested path forward (often a plan revision)
- **`escalation: phase-too-big`**: the phase exceeded a single executor's reasonable scope. Split it into smaller ordered sub-phases (function-grained) and dispatch those — or, if it can't be cleanly split, stop and ask for a plan revision.

Escalation is efficiency, not failure. Never power through a 3-strike failure.
