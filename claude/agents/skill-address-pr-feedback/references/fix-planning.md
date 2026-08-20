# Fix Planning — skill-address-pr-feedback

Load this after confirmed triage.

Split fix work into two tracks:

- Behavioral fixes: dispatch `implementation-executor` with RED tests, GREEN changes, success criteria, allowed paths, verification commands, and constraints.
- Non-behavioral edits: dispatch `quick-implement-agent` direct-edit phases for renames, comments, docs, formatting, dead-code removal, and pure config.

One reviewer concern should become one phase unless a single comment contains multiple behaviors. Re-verify every phase independently before marking the comment addressed.

Plan only Confirmed Fixes and the portion of Partially Correct feedback the user
selected. `Scope Decision Required` is not a fix phase: pause for the explicit
requirement decision. A follow-up ticket is appropriate for an adjacent
non-blocking improvement, but never substitutes for acceptance of a must-have
scope reduction.
