## Step 4 — Sort Fixes Into Two Tracks

For each **Confirmed Fix** and **Partially Correct** item that survived Act I, decide its track:

- **Behavioral fix (→ executor phase).** The fix changes runtime behavior, and a test could fail before the fix and pass after it: bug fixes, logic changes, new edge-case handling, corrected return shapes, validation. These get a TDD phase dispatched to `implementation-executor`.
- **Non-behavioral direct edit (→ quick-implement-agent).** The fix has no honest failing test: renames, comment/docstring wording, log-level changes, formatting, dead-code removal, doc files, pure config. You dispatch these as `direct_edit` phases to `quick-implement-agent` in Act III — they clear the same format/lint/test SubagentStop gate as behavioral fixes.

When in doubt, prefer the executor track — but never invent a vacuous test just to route a fix through it. The executor **rejects a phase with no `red_tests`**; a fix that can't produce a genuine RED test belongs in the direct-edit track.
