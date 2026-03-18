# Verification Commands by Stack

Quick reference for common verification commands. **Always check the project's CLAUDE.md for project-specific CI commands — those take precedence.**

## Elixir
```bash
mix test                          # run tests
mix test test/path/specific_test.exs  # run specific test file
mix credo --strict                # static analysis
mix format --check-formatted      # formatting check
mix compile --warnings-as-errors  # catch warnings
mix dialyzer                      # type checking (if configured)
```

## Python
```bash
pytest                            # run tests
pytest tests/path/test_file.py    # run specific test file
ruff check .                      # linting
ruff format --check .             # formatting check
bandit -r src/                    # security linting
mypy src/                         # type checking (if configured)
```

## React/TypeScript
```bash
yarn test                         # or npm test
yarn test -- --testPathPattern=path/to/test  # specific test
yarn lint                         # or npm run lint
yarn typecheck                    # or npx tsc --noEmit
```

## Ruby
```bash
bundle exec rspec                 # run tests
bundle exec rspec spec/path/file_spec.rb  # specific test
bundle exec rubocop               # linting
```

## E2E (Playwright)
```bash
npx playwright test               # run all
npx playwright test tests/path/test.spec.ts  # specific test
npx playwright test --ui          # interactive mode
```
