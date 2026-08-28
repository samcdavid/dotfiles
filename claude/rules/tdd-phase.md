# TDD Phase Contract

For implementation phases:

1. RED: write the specified failing test first and prove it fails for the intended behavioral reason.
2. GREEN: write the minimum production code needed to pass.
3. VALIDATE: run every success criterion and verify the diff satisfies the behavioral requirement.

Derive tests only from desired outcomes. For each outcome, write the smallest
test that proves the returned value, public error, user-visible behavior,
persisted state, or explicitly requested external effect. Do not add separate
tests for the mechanisms used to produce it: telemetry/log emission, database or
cache access, collaborator calls, locks/semaphores, retries, private helpers,
call order, or framework/supervisor policy. An implementation detail becomes a
test outcome only when the requirement explicitly makes that externally
observable effect the product behavior—not merely an architecture,
observability, performance, or implementation constraint.

One outcome should normally have one test at the lowest level that proves it.
Do not duplicate the same outcome across unit, integration, and interaction
tests. Verify non-behavioral constraints with review, static analysis,
benchmarks, or another mechanical check outside the behavioral test suite.

For failure recovery, exercise the public behavior before and after the failure
and assert only the known-good recovered result. At integration boundaries,
assert the externally observable result or stable postcondition; doubles may
control an external or nondeterministic boundary, but tests must not assert the
double interaction as an additional outcome.

Required phase inputs: phase overview, RED tests, behavioral test contracts, GREEN changes, allowed paths, success criteria, verification commands, and architectural constraints.

Missing RED tests, behavioral test contracts, or success criteria is a planning failure; stop instead of inventing them.
