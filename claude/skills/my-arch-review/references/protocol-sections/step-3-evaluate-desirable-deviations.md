## Step 3 — Evaluate Desirable Deviations

Not all convention breaks are bad. Evaluate whether a deviation is:

**Desirable** — the deviation improves the architecture:
- Introduces a better pattern that should eventually replace the old one
- Breaks a convention that was itself problematic (with clear rationale)
- Simplifies a previously over-engineered area
- Creates a clear migration path from old pattern to new

**Undesirable** — the deviation degrades the architecture:
- Introduces inconsistency without clear benefit
- Takes a shortcut that creates technical debt
- Copies a pattern from a different context where it made sense but doesn't here
- Makes the "wrong thing easy and the right thing hard" for future changes

For each deviation, state whether it's desirable or not and WHY.
