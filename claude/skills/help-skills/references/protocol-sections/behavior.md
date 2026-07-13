## Behavior

If `$ARGUMENTS` contains a description of what the user wants to do:
- Match it against the skill catalog below
- Recommend the best-fit skill(s) with a brief explanation of why
- If multiple skills could apply, rank them and explain the tradeoffs
- If no skill fits, say so and suggest whether one should be built

If `$ARGUMENTS` is empty or "list":
- Print the full catalog grouped by category
