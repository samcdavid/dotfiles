# TDD Phase Contract

For implementation phases:

1. RED: write the specified failing test first and prove it fails for the intended behavioral reason.
2. GREEN: write the minimum production code needed to pass.
3. VALIDATE: run every success criterion and verify the diff satisfies the behavioral requirement.

Tests specify an observable outcome or stable postcondition—not the implementation path used to reach it. Assert returned values, public errors, persisted state, emitted contracts, or later behavior a caller can observe. Do not assert a query executed, a private helper was called, an internal call sequence occurred, or a framework/supervisor policy was selected unless that detail is itself the stated external contract.

For failure recovery, exercise the public behavior before and after the failure and assert the known-good recovered result. Do not treat a supervisor callback or restart-policy assertion as proof that the system recovered correctly. At integration boundaries, assert the externally observable result and stable postcondition; use doubles only to control an external or nondeterministic boundary, not to mock away the behavior under test.

Required phase inputs: phase overview, RED tests, behavioral test contracts, GREEN changes, allowed paths, success criteria, verification commands, and architectural constraints.

Missing RED tests, behavioral test contracts, or success criteria is a planning failure; stop instead of inventing them.
