# Ecto Migration Planning

Load this reference when the project changes Ecto migrations, persisted schema, constraints, indexes, or data that requires a migration/backfill. It complements the repository-wide migration-history and compatibility requirements in `../../my-workflow/references/migration-safety.md`; read that reference too when it is available.

## Ticket boundary and release ordering

Create migration-only issue(s), each mapped to one PR, before the functional issue(s) they enable. A migration issue contains no user-facing feature behavior; a functional issue contains no migration. The functional issue is blocked until the migration PR has been deployed and the migration's acceptance evidence is available.

For an incompatible change, plan expand/migrate/contract rather than one risky edit. The initial migration-only work can add compatible schema or write paths; backfill and validation are separate, observable work where needed; destructive cleanup is a later migration-only issue after every deployed application version no longer reads or writes the old shape. Never make a later cleanup migration share a PR with functional work simply to preserve an artificial project order.

## Safe Ecto recipes to encode in the migration issue

Use the relevant recipe from [fly-apps/safe-ecto-migrations](https://github.com/fly-apps/safe-ecto-migrations) and record it in the issue acceptance criteria. At minimum, account for these rules:

- Indexes: PostgreSQL indexes on live tables use `concurrently: true`; a concurrent migration disables the DDL transaction and retains an advisory migration lock when the application supports it. Do not mix unrelated operations into that migration.
- References, check constraints, and NOT NULL: add as `validate: false`/`NOT VALID`, backfill when necessary, and validate in a separate migration. A foreign-key or check validation must not be bundled with the initial add.
- Defaults: add a column without a volatile default, set the default separately, and plan a backfill only when existing rows need materialized values. Do not use `modify/3` merely to alter a default when it can rewrite the column type.
- Type, column, and table renames/removals: prefer a compatible field/source mapping when possible. Otherwise add a new shape, dual-write, backfill, move reads, remove old application references, then separately drop the old shape.
- JSON: use `jsonb` rather than `json` on PostgreSQL unless the research proves a different type is required.

The guide is recipe-oriented rather than a substitute for repository-specific evidence. The issue must also state table size/traffic assumptions, database version, affected deployment histories, lock/rollback risk, history audit and compatibility-matrix rows, migration validation commands, and the staging/production health signals required before unblocking functional work.

## Required issue acceptance criteria

Each migration-only issue must say:

1. The exact schema/data change and Safe Ecto recipe used.
2. The compatibility guarantee for old and new application versions.
3. Any backfill/constraint-validation phase and the required observation or completion evidence.
4. The histories/environments the migration must support and how they will be validated.
5. The dependent functional issue IDs and the condition that unblocks them.

Do not declare a migration ready based only on a fresh database. The implementation workflow must perform the history audit and compatibility matrix in `../../my-workflow/references/migration-safety.md` before validation or release claims.
