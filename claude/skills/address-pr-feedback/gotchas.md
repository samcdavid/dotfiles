# Gotchas — address-pr-feedback

Known failure patterns and lessons learned. Read before starting work with this skill.

### Ecto concurrent index migrations: use DSL, not raw SQL
- **Category:** anti-pattern
- **Context:** Writing Ecto migrations that drop or create indexes concurrently (requires `@disable_ddl_transaction true`)
- **Wrong:** `execute "DROP INDEX CONCURRENTLY IF EXISTS my_index_name"` — triggers credo's `Raw sql executed` check
- **Right:** `drop_if_exists index(:table_name, [:col1, :col2], concurrently: true)` — uses the Ecto migration DSL, passes credo
- **Why:** Credo enforces no raw SQL in migrations. The Ecto DSL has full support for concurrent index operations and resolves the index name automatically from column list, or accepts an explicit `name:` option for named indexes
- **Source:** Migration that replaced a raw `execute "DROP INDEX CONCURRENTLY..."` to fix credo CI failure

### Ecto concurrent index migrations: both `up` and `down` need `concurrently: true`
- **Category:** edge-case
- **Context:** Writing `up`/`down` for a migration that uses `@disable_ddl_transaction true` for concurrent index operations
- **Wrong:** Only adding `concurrently: true` to index operations in `up`, leaving `down` without it
- **Right:** Every `drop_if_exists`, `create_if_not_exists`, `create`, and `drop` for indexes in BOTH `up` and `down` must include `concurrently: true` when `@disable_ddl_transaction true` is set
- **Why:** Credo's migration checks scan all clauses, not just `up`. A non-concurrent index op in `down` while the module declares `@disable_ddl_transaction true` triggers `Index not concurrently` warnings
- **Source:** Migration `down` function that was missing `concurrently: true` on its `drop_if_exists` call, caught by credo CI
