## Step 8 — Re-review Pattern Capture

Only fires when Step 1 detected existing review comments from your prior review pass on this PR. Skip entirely otherwise.

After the verdict is finalized, look at any PR comments (from other reviewers or the author) that surfaced since your last pass:

1. Classify each: `Already-flagged-by-you` / `Out-of-scope` / `Worth-considering`.
2. For the `Worth-considering` set, ask one batched question:
   > "Do any of these point to a pattern the skill should have caught? [numbers or 'none']"
3. For each selected comment:
   - Check `references/learned-misses.md` for an existing matching Shape; append a new Evidence entry (`type: missed`, today's date, `ref` = comment link) if found.
   - Otherwise, draft a Shape and Trigger signals, confirm with me, then append a new entry under `## Pending` with `status: pending`.

If no `Worth-considering` items, skip the prompt entirely.
