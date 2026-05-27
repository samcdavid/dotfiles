# Gotchas — address-pr-feedback

Known failure patterns and lessons learned. Read before starting work with this skill.

### Elixir multi-clause function grouping broken by interleaved helpers
- **Category:** failure-mode
- **Context:** When adding a new clause to an existing multi-clause function (e.g. a catch-all or pattern-match clause), and also adding an unrelated helper function in the same edit
- **Wrong:** Inserting a new function definition (`def helper/1`) between existing clauses of the same function (`def error_message/1`), producing interleaved definitions
- **Right:** Keep all clauses of the same function/arity grouped together. Place any new helper functions before or after the entire group, never inside it
- **Why:** Elixir emits a "clauses with the same name and arity should be grouped together" warning for interleaved function definitions. With `--warnings-as-errors` (standard CI config) this fails compilation. The formatter may also reorder things in a way that makes the grouping violation non-obvious until compile time.
- **Source:** Observed when adding a `%Ecto.Changeset{}` clause to a view helper alongside extracting an SVG function component in the same file

### Brand/product name capitalisation in user-visible copy
- **Category:** convention
- **Context:** Writing or editing user-visible strings in templates — error messages, labels, button copy, scope descriptions, alt text
- **Wrong:** Using lowercase product name (e.g. `brandname`) in body copy when the correct brand form is capitalised (`BrandName`)
- **Right:** Check the correct capitalisation for any product or brand name appearing in copy before writing it. When in doubt, grep for existing uses in the codebase rather than guessing
- **Why:** Brand names have prescribed capitalisation that differs from standard English title case. Getting it wrong in user-facing copy requires a follow-up fix and a re-review round
- **Source:** Observed when writing scope description and account copy in an OAuth consent page template

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
