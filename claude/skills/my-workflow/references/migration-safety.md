# Migration Safety

Use this reference whenever a task adds, removes, renames, retimestamps, or changes a database migration; changes persisted schema/data; or repairs a failed database deployment. A migration version is durable database identity, not just a filename.

## Local Planning and Test Gate

During pair planning, write a durable `Migration and Operational Readiness`
section in the workflow ledger. It must contain:

- The migration's intended schema/data change, ordering, compatibility approach,
  lock or rollback risk, and any required reconciliation.
- The repository test-suite command. The normal test setup applies migrations,
  so a passing suite is the local evidence that migrations execute.
- Assertions in that suite for the schema/data behavior the change enables,
  when such assertions are practical.
- A staging-validation checklist, marked `pending_developer_staging_validation`
  until the developer performs the staging deployment.

Do not inspect a current target database, reconstruct historical database
states, or demand staging artifacts during local planning or implementation.
The developer validates current migration state only by deploying to staging.

## Staging Validation

After the developer deploys to staging, record the deployed version and check:

1. The migration completes successfully against the actual staging state.
2. Required tables, columns, indexes, constraints, and data invariants exist.
3. Any migration-specific retry or rerun behavior works as intended.
4. The deployed application starts and operates without schema exceptions.
5. Target/service health and migration error monitors remain healthy.

Staging validation is deployment evidence, not a prerequisite for synchronizing
a plan, passing the local pre-implementation gate, implementing, committing,
or local review. A failed staging check is a deployment finding: record the
observed state and investigate before proposing a corrective migration.

## Release Observation and Incident Handling

The observability plan for a migration must name the staging and production health checks, error monitors, and expected baseline. After a rollout, verify the new image version, migration completion, target/service health, and absence of new schema exceptions.

If a deployment produces schema exceptions or unhealthy targets, switch to
incident investigation before proposing another fix. Confirm the deployed image
SHA and observed database state, record it in the staging result, and do not
assert that a retry or follow-up migration will recover the environment without
evidence.

## Review Questions

- Does the migration preserve a safe ordering and compatibility approach?
- Does any reconciliation precede the migration that depends on it?
- Does the test suite apply the migration and cover its enabled behavior?
- Does the staging checklist verify the actual schema, rerun/retry behavior, and
  application startup?
