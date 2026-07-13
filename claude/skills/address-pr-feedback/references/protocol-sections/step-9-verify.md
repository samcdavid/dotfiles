## Step 9 — Verify

Per-phase work was already verified by the executor, its `SubagentStop` hook, and your independent re-verify. During iteration, run the narrowest affected check first. This step is the **holistic gate** — run broader checks once over the combined result:

### Build / Compile

- Elixir: `mix compile --warnings-as-errors`
- TypeScript: `npx tsc --noEmit`
- Python: `uv run ruff check` + `uv run ruff format --check`

### Lint / Format

- Elixir: `mix format --check-formatted` + `mix credo` (if present)
- TypeScript: `npx eslint .` + `npx prettier --check .`
- Python: `uv run ruff check` + `uv run ruff format --check`

### Tests

- Elixir: `mix test`
- TypeScript: `npm test`
- Python: `uv run pytest`

For each fix, start with the smallest affected test file or command. Save domain/package/full-suite checks for the final gate unless the narrow check cannot exercise the change.

If the project has a `Makefile`, `justfile`, or CI script, prefer those over individual commands.

When a compile/lint warning appears, first check whether its path intersects `git diff --name-only`. If it does not intersect, treat it as likely pre-existing and report it separately. Use stash-and-recompile only when path attribution is ambiguous.

If any check fails, fix the issue before proceeding. Do not leave the branch in a broken state.
