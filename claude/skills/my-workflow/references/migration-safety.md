# Migration Safety

Use this reference whenever a task adds, removes, renames, retimestamps, or changes a database migration; changes persisted schema/data; or repairs a failed database deployment. A migration version is durable database identity, not just a filename.

## Required History Audit

Before architecture planning, create a durable migration-history artifact beside the workflow's research artifacts and link it from the ledger. It must contain:

- The migration-version map at the merge base and at HEAD, including duplicate, renamed, and retimestamped versions.
- The code/version currently deployed to every target environment and whether it expects schema that may be absent.
- Read-only evidence for each target database's relevant `schema_migrations` entries and schema objects. Use deployment logs and observability data when direct database access is unavailable; record the limitation rather than inferring a clean state.
- Every distinct history the change must support, with its starting migration records and schema state.

Treat an unknown deployed history as a required matrix row, not as permission to assume a fresh database.

## Compatibility Matrix

The spec and implementation plan must name the expected outcome for each relevant state. At minimum include:

| History | Expected migration behavior | Required postcondition |
|---|---|---|
| Fresh database | All migrations run once in order | Complete schema and recorded versions |
| Previously deployed version | New migrations apply without recreating old objects | Existing data/schema preserved |
| Collision or partial history | Reconciliation runs before dependent work | Missing schema is created and validated |
| Current production state | Application code and schema remain compatible throughout rollout | No missing-column/table/constraint errors |

If a migration version may already be recorded with a different body, do not treat a rename or retimestamp as a standalone repair. Plan an explicit reconciliation path that executes before any dependent migration. Prefer new forward-only repair migrations; modifying a historical migration needs a matrix row for every database that might have already applied it.

## Validation Gate

Run migration validation against disposable PostgreSQL databases for every matrix row. At minimum:

1. Migrate an empty database to HEAD.
2. Recreate each recorded-version/schema history from the matrix, then migrate it to HEAD.
3. Assert required tables, columns, indexes, constraints, data invariants, and `schema_migrations` versions.
4. Re-run migration to confirm idempotence where the plan claims it.
5. Build or start the same application artifact that will deploy and verify it against the migrated database.

Static uniqueness checks, formatting, and a clean `ecto.setup` are necessary but insufficient. They do not prove compatibility with a database that has historical migration records.

If any required simulation cannot run, record the command, blocker, and affected matrix rows as `migration_safety: blocked`. Do not mark implementation valid, commit it as a validated phase, or take an outward action. A user may explicitly direct an override; record the exact override, residual risk, and that the gate remains blocked.

## Release Observation and Incident Handling

The observability plan for a migration must name the staging and production health checks, error monitors, and expected baseline. After a rollout, verify the new image version, migration completion, target/service health, and absence of new schema exceptions.

If a deployment produces schema exceptions or unhealthy targets, switch to incident investigation before proposing another fix. Confirm the deployed image SHA and database history, update the matrix with the observed state, and do not assert that a retry or follow-up migration will recover the environment without evidence.

## Review Questions

- Does every version retain one unambiguous meaning for every deployed database?
- Can a target database have a recorded version without the schema this branch assumes?
- Does reconciliation precede every migration that depends on the missing object?
- Are retimestamped or changed migrations safe when their former body already ran?
- Does the planned rollout ever run code that requires schema before that schema is present?
