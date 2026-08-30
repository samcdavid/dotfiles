# Code and Domain Gotchas — address-pr-feedback

These are repair-time code and contract traps. Ledger, validation, publication,
and thread-cleanup requirements belong in `references/execution-contract.md`.

## Test both directions of a gate helper's contract

When repairing an authorization, rollout, or registration wrapper, do not rely
on hidden/denied coverage. Add an allowed-path test that proves authenticated
identity and arguments reach the resolver, ordering is resolver → gate →
handler, the handler runs once, and its result returns.

## State the authorization responsibility of injected resolvers

When a helper accepts an account or resource resolver then applies a later gate,
document and test that the resolver establishes membership/ownership before
returning the target ID. A later rollout gate is not an authorization substitute.

## Audit replacement registration helpers against the platform wrapper contract

A custom replacement for a shared decorator must preserve inherited telemetry,
session validation order, context enrichment, and handler composition. Add a
real-handler regression whenever the first live tool defines that composition.

## Treat focused static analysis as part of typed-wrapper acceptance

For forwarded typed keyword options or decoded JSON, inspect the concrete
dependency signature, model supported options precisely, narrow decoded values
before nested access, and run the relevant type checker as well as lint.

## Export every contract needed to consume a public result wrapper

When a root facade exports a result/failure wrapper containing a concrete error
union, export the union, variants, and discriminators too. Test construction and
narrowing through only the public facade.

## Axon Ecto queries use pipe style

When reviewing or repairing Axon Ecto queries, prefer `Schema |> join(...) |>
where(...) |> select(...) |> repo.all()` over `from(...)`. Treat a requested
conversion as an accepted code-style correction, not optional churn; retain
`from` only for a documented construct-specific exception. Keep tests focused
on query behavior rather than source-token counts.

## Never reset a database without verified, target-specific permission

Before any database reset, drop, recreate, truncate, or equivalent destructive
test-state command, independently resolve the effective host, port, and database
name from the command's actual environment and show that exact target to the
user. Obtain explicit permission for that verified target immediately before
running the command; permission based on an assumed or described-as-isolated
target is invalid. Do not delegate or execute the operation until both checks
are complete. A worktree label or intended Compose stack does not prove database
isolation, and targeting a shared test database can destroy other worktrees'
state and interrupt their tests.
