# Verification Commands by Stack

Quick reference for common verification commands. **Always check the project's CLAUDE.md for project-specific CI commands — those take precedence.**

## TDD Cycle Commands

The RED/GREEN/REFACTOR cycle uses the same test runners — the difference is WHEN you run them and WHAT you expect:

| Step | Run | Expect |
|------|-----|--------|
| **RED** | Run the new test(s) only | FAIL (test exists, asserts correct behavior, but production code doesn't exist yet) |
| **GREEN** | Run the new test(s) + full suite | ALL PASS (new code satisfies the test, nothing else broke) |
| **REFACTOR** | Run full suite | ALL PASS (behavior unchanged after cleanup) |

**RED verification**: Run ONLY the new test file/test case. Confirm it fails for the right reason — missing function, wrong return value, etc. NOT a syntax error or import failure.

**GREEN verification**: Run the specific test first, then the full suite. Both must pass.

## Elixir
```bash
# RED — run only the new test (expect failure)
mix test test/path/specific_test.exs --seed 0
# GREEN — run specific test, then full suite
mix test test/path/specific_test.exs
mix test
# Static analysis
mix credo --strict                # static analysis
mix format --check-formatted      # formatting check
mix compile --warnings-as-errors  # catch warnings
mix dialyzer                      # type checking (if configured)
```

## Python

**Detect the runner first.** Check for these files in order — use the first match:

| File | Runner | Prefix |
|------|--------|--------|
| `uv.lock` | uv | `uv run` |
| `poetry.lock` | poetry | `poetry run` |
| `Pipfile.lock` | pipenv | `pipenv run` |
| none of the above | bare venv/global | (none) |

Almost always `uv`. When in doubt, check `pyproject.toml` for `[tool.poetry]` vs `[tool.uv]`.

```bash
# Detect runner (run once at start of implementation)
# Look for: uv.lock → uv | poetry.lock → poetry | else → bare
#
# Examples below use $RUN as placeholder — substitute the detected prefix.
# uv → "uv run", poetry → "poetry run", bare → ""

# RED — run only the new test (expect failure)
$RUN pytest tests/path/test_file.py::test_name -x
# GREEN — run specific test, then full suite
$RUN pytest tests/path/test_file.py
$RUN pytest
# Static analysis
$RUN ruff check .                 # linting
$RUN ruff format --check .        # formatting check
$RUN bandit -r src/               # security linting
$RUN mypy src/                    # type checking (if configured)
```

## Node.js / TypeScript

**Detect the package manager first.** Check for these lock files in order — use the first match:

| File | Manager | Run command |
|------|---------|-------------|
| `yarn.lock` | yarn | `yarn` / `yarn run` |
| `pnpm-lock.yaml` | pnpm | `pnpm` / `pnpm run` |
| `package-lock.json` | npm | `npm run` / `npx` |
| `bun.lockb` | bun | `bun` / `bun run` |

Also check `package.json` for the `test`, `lint`, and `typecheck` script names — they vary per project.

```bash
# Detect manager (run once at start of implementation)
# Look for: yarn.lock → yarn | pnpm-lock.yaml → pnpm | package-lock.json → npm | bun.lockb → bun
#
# Examples below use $PM as placeholder — substitute the detected manager.

# RED — run only the new test (expect failure)
$PM test -- --testPathPattern=path/to/test --no-coverage
# GREEN — run specific test, then full suite
$PM test -- --testPathPattern=path/to/test
$PM test
# Static analysis
$PM run lint                      # check package.json for script name
$PM run typecheck                 # or: npx tsc --noEmit
```

## Ruby
```bash
# RED — run only the new test (expect failure)
bundle exec rspec spec/path/file_spec.rb:LINE
# GREEN — run specific test, then full suite
bundle exec rspec spec/path/file_spec.rb
bundle exec rspec
# Static analysis
bundle exec rubocop               # linting
```

## E2E (Playwright)
```bash
# RED — run only the new test (expect failure)
npx playwright test tests/path/test.spec.ts --grep "test name"
# GREEN — run specific test, then full suite
npx playwright test tests/path/test.spec.ts
npx playwright test
# Interactive
npx playwright test --ui          # interactive mode
```
