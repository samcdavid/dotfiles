## Step 1 — Parse arguments

`$ARGUMENTS` may contain an optional iteration limit and/or a goal description.

- If `$ARGUMENTS` starts with a number (e.g. `100`, `50`), treat it as the **iteration limit**. The rest (if any) is the goal.
- If `$ARGUMENTS` is only a number, use the iteration limit but determine the goal from context (see below).
- If `$ARGUMENTS` has no number, there is no iteration limit — loop forever.

Examples: `/autoresearch 100` = 100 iterations, goal from context. `/autoresearch 50 improve test coverage` = 50 iterations, goal is "improve test coverage". `/autoresearch reduce bundle size` = no limit, goal is "reduce bundle size".
