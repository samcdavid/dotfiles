# Fix Planning

Load this after confirmed triage.

Split fix work into two tracks:

- Behavioral fixes: dispatch `implementation-executor` with RED tests, GREEN changes, success criteria, allowed paths, verification commands, and constraints.
- Non-behavioral edits: dispatch `quick-implement-agent` direct-edit phases for renames, comments, docs, formatting, dead-code removal, and pure config.

One reviewer concern should become one phase unless a single comment contains multiple behaviors. Re-verify every phase independently before marking the comment addressed.

