# Fix Planning — skill-address-pr-feedback

Load this after confirmed triage.

Split fix work into two tracks:

- Behavioral fixes: invoke `my-implement` with RED tests, GREEN changes, success criteria, allowed paths, verification commands, and constraints.
- Non-behavioral edits: invoke `my-implement` in direct-edit repair mode for renames, comments, docs, formatting, dead-code removal, and pure config.

Group comments by verified root cause before planning. One bounded phase may
address multiple comments only when they share that cause, behavior contract,
allowed paths, and focused test setup. Do not batch independent causes merely
because they are nearby in the diff. Re-verify each batch independently before
marking every included comment addressed.

Classify each batch against the feedback-fast-lane criteria in `protocol.md`.
For an eligible batch, pass a pre-confirmed micro-fix contract to `my-quick`:
triage evidence, one behavior contract, allowed paths, and the focused proving
check. `my-quick` must return to normal feedback handling when its tripwire
fires. All other batches use `my-implement` directly.

Plan only Confirmed Fixes and the portion of Partially Correct feedback the user
selected. `Scope Decision Required` is not a fix phase: pause for the explicit
requirement decision. A follow-up ticket is appropriate for an adjacent
non-blocking improvement, but never substitutes for acceptance of a must-have
scope reduction.
