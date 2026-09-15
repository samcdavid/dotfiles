# Category Detection Heuristics

These are starting heuristics, not an exhaustive spec — the point is to catch the common shapes cheaply from a diff, not to build a static-analysis tool. When a hunk is ambiguous, use judgment from surrounding code rather than skipping it.

## Product requirement changes

- Changed literal thresholds, limits, or magic numbers in business logic (`MAX_*`, `*_LIMIT`, percentage/rate constants).
- Changed validation rules: added/removed a required field, changed a regex/format check, changed an allowed-values list.
- Changed permission/role/authorization checks that alter who can do what.
- Changed user-facing copy tied to a rule (error messages, tooltips) when the surrounding logic also changed — copy-only changes with no logic change are not a requirement change.

## Modified existing tests

- Diff touches a file matching `*_test.*`, `*_spec.*`, `test_*.py`, `__tests__/`, `spec/` etc., where the file already existed before the diff (not a new test file).
- Within that, distinguish: assertion value/condition changed (behavior expectation changed) vs. mechanical refactor (rename, setup/teardown, formatting) — call out the former more prominently.

## New database migrations

- New files under conventional migration directories (`db/migrate/`, `migrations/`, `alembic/versions/`, `prisma/migrations/`, `ecto/priv/repo/migrations/`).
- New Alembic/Rails/Django/Ecto migration classes/modules.
- ORM model changes (new/removed/retyped field on a model/schema class) that imply a migration should exist — flag if no matching migration file appears in the same diff, since that's a common miss worth surfacing.

## Function/method signature changes

- Diff hunk touches a `def`/`function`/method declaration line itself (not just its body): parameter added/removed/reordered, type annotation changed, default value changed, return type changed.
- Language-agnostic tell: the changed line contains a parameter list `(...)` and is a declaration, not a call site.

## Public interface changes

- Exported symbols: `export`, `public`, `pub fn`, top-level classes/functions in a module's `__init__.py`/`index.ts` barrel file, or anything re-exported.
- API route/controller definitions: new/removed/changed HTTP route, GraphQL field/resolver, gRPC/protobuf service method.
- Changes to a versioned public contract file (OpenAPI/Swagger spec, `.proto`, GraphQL schema `.graphql`).

## Branching-condition changes

- Diff touches an `if`/`elif`/`else if`/`case`/`switch`/`when`/guard-clause line's condition expression (not just the body under it).
- Especially flag conditions that change which branch executes for existing inputs (tightened/loosened comparison, flipped boolean, added/removed `&&`/`||` clause) versus purely added new branches for new inputs.

## Feature flag use

- New flag check introduced: calls like `flag_enabled?`, `feature?`, `ld_client.variation`, `unleash.isEnabled`, `if os.environ.get("FEATURE_...")`, config-driven `flags.yaml`/`flags.json` entries.
- Existing flag check removed (flag being retired/cleaned up) — note this distinctly from a new flag being added, since cleanup and new-gating carry different review attention.
- Changed flag default/rollout percentage in a config file.

# Diff Acquisition Notes

- PR mode: `gh pr diff <N>` gives the full unified diff; combine with the scoped GraphQL/REST field projections from `pr-cost-control.md` only if per-file/per-line metadata (not diff content) is needed. Do not fetch full file contents unless a hunk's context is insufficient to categorize — then use `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` per `pr-mode-readonly.md`, never the local working tree.
- Local mode: `git diff <merge-base>...HEAD` plus `git diff` for uncommitted changes; state which of the two (or both) were included in the summary.
