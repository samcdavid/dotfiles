## Loop Detection (orchestrator-owned)

- **First failure** (criterion fails or agent escalates): diagnose from report + diff. If the brief was thin (missing path, ambiguous description), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total across agent + your re-runs): **STOP.** Present to the user: what the phase was trying to do, what keeps failing (+ error output), what's been tried, your root-cause theory, suggested path forward.
- **`escalation: phase-too-big`**: split the phase into smaller ordered phases and dispatch those, or ask for a plan revision.

Escalation is efficiency, not failure. Never power through a 3-strike failure.
