# Self-Review Checklist — my-quick

Used by Step 7 of `/my-quick`. Walk the diff against these categories. Surface findings as text — do NOT auto-edit.

**Reminder:** this is a self-review by the same Claude that wrote the code. It's a sanity check for obvious issues, not a substitute for `/my-review`.

## Correctness

- Does the change do what the Step 4 mini-plan said it would do? (Re-read the plan.)
- Edge cases: nil, empty list, empty string, negative number, zero, boundary off-by-one?
- Pattern matches / conditionals: every branch reachable? Catch-all for the unexpected?
- Bang vs. non-bang function choice — `!` raises; non-bang returns `{:ok, _} | {:error, _}` or similar. Right one for the call site?
- Error paths exercised, or only the happy path?

## Blast Radius

- Did I change anything beyond what the mini-plan said?
- Any caller / consumer of changed code that I didn't update?
- Removed a guard, feature flag, or check — did I silently broaden behavior?

## Tests

- Does the test actually exercise the new behavior? Not vacuously passing?
- Both sides of any new conditional covered?
- Assertion specificity — checking the right values, not just "no error raised"?
- Test name describes the behavior, not the implementation?

## Cleanliness

- Dead code, unused imports, orphaned helpers?
- Names match domain concepts? (A variable called `type` when it means `screener_type` costs future readers.)
- Magic numbers / strings extracted to constants where it matters?
- Comments only where the WHY isn't obvious from the code?

## Lint / Format Discipline

- Did I disable any lint check, formatter rule, or warning suppression? (`# credo:disable-for-this-file`, `# noqa`, `// eslint-disable`, `@dialyzer`, `# rubocop:disable`, `mix format` skip comments, etc.) Every disable is a finding unless I can defend the justification.

## Output Format

Group findings by severity. Be explicit when there are no findings — don't pad.

```
### Self-Review Findings

**Bugs (would break in production):**
- <none> or <list with `file:line` and one-line description>

**Suggestions (worth fixing now):**
- <none> or <list with `file:line` and one-line description>

**Nits (low priority):**
- <none> or <list>

**Note:** This is a self-review by the same Claude that implemented the change. It's a sanity check, not a substitute for `/my-review`.
```

If everything passes:

> "Self-review found no issues. Sanity check only — for substantive changes, run `/my-review` for an independent pass."
