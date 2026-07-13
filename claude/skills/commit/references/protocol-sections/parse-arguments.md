## Parse Arguments

`$ARGUMENTS` may contain:
- A ticket/card reference (e.g. `ENG-123`, a Linear URL, a GitHub issue) → include in Related Cards
- File paths or globs → only consider those files instead of all changes
- `--amend` → amend the previous commit instead of creating a new one
- A brief description of what the change does → use as context for writing the message, not as the message itself
- If empty → consider all changes and infer everything from the diff
