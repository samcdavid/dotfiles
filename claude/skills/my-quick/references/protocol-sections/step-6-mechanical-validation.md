## Step 6 — Mechanical Validation

Run, in order:

1. The full test file for the changed area
2. Linter / formatter scoped to changed files
3. Type checker if the language has one

Self-repair is allowed for trivial failures (formatting, lint nits). For type errors or test failures that aren't trivially fixable, surface them — don't blunt-force.
