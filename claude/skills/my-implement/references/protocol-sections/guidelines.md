## Guidelines

- **You orchestrate; the executor implements.** Don't write the tests or production code in the main context — dispatch them. Your job is slicing, verifying, and loop control.
- **Tests before code — always**, enforced inside every executor. A phase with no RED tests does not get dispatched.
- One executor at a time; phases are sequential.
- Keep each slice minimal — the executor's context should be small, which is the whole point.
- Commit nothing and push nothing — this skill produces verified working-tree changes only. Outward git actions are the user's call.
- The plan is the WHAT; the executor decides the HOW for its phase, within `allowed_paths` and `architectural_constraints`.
