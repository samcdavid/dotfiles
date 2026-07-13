## Step 3 — Apply the TDD Gate to Each Phase

For each item from Step 2, classify it:

### FULL TDD phase — use when the change:
- Adds new behavior (new function, new edge case, new return shape)
- Fixes a bug (the failing test IS the specification)
- Changes observable behavior that callers would notice
- Can be expressed as: "it should fail this test before the edit, pass it after"

**TDD phase fields:**
- `red_tests` — the test(s) to write first (paths + what each asserts)
- `green_changes` — the production code change (paths + descriptions)
- `success_criteria` — RED: test exists and fails; GREEN: test passes; additional lint/grep checks

### DIRECT EDIT phase — use when the change is:
- Pure restructuring: extracting a helper, inlining a function, reordering clauses — no behavior change
- Pure renaming: variable, function, module — logic unchanged
- Simplification: removing dead code, replacing verbose with concise, no semantic change
- Comment, type annotation, or docstring changes only

**Direct-edit phase fields:**
- `edit_target` — specific file path + function name + line range
- `edit_description` — full description of the edit (enough for an agent with no prior context to execute it precisely)
- `success_criteria` — grep confirms new form exists, lint passes, relevant test suite unchanged

When in doubt, prefer FULL TDD. A refactor that can produce an honest failing test before the edit is a TDD phase, not a direct-edit phase.
