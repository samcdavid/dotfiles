## What this is — and is not

- This skill **runs the real skills in order via the Skill tool**. It does NOT reimplement them. Each stage's skill remains the single source of truth for that stage.
- Contrast with `/my-quick`: that collapses a *subset* of this flow into one fast inline pass for small, well-understood changes. `my-workflow` is the deliberate opposite for substantial work. If intake routes to `my-quick`, record that route and reason in the workflow ledger before handing off.
- It performs **no outward git actions**. It never commits, pushes, or opens a PR. The hand-off summary is the stopping point.
