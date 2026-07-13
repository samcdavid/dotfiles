## Step 5: Verify

Run these checks after updates. The exact commands depend on the ecosystem.

| Check | Commands by ecosystem |
|-------|----------------------|
| **Compile/build** | `mix compile --warnings-as-errors` / `npx tsc --noEmit` / `uv run python -m py_compile` / `cargo build` |
| **Format** | `mix format --check-formatted` / `npx prettier --check .` / `uv run ruff format --check` / `cargo fmt --check` |
| **Lint** | `mix credo` (if present) / `npx eslint .` / `uv run ruff check` / `cargo clippy` |
| **Test** | `mix test` / `npm test` / `uv run pytest` / `cargo test` |

Run whatever subset applies to the project. If the project has a `Makefile`, `justfile`, or scripts in `package.json`, prefer those (e.g. `make check`, `just test`, `npm run lint`).

If any check fails: fix the issue before proceeding.
