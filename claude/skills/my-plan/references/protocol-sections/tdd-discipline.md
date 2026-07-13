## TDD Discipline
Every phase is one small unit of behavior (a single function/method where possible) and follows red/green/validate:
1. **RED** — Write the test(s) first. They MUST fail before any production code is written.
2. **GREEN** — Write the minimum production code to make the tests pass (fold in any obvious, behavior-preserving cleanup here).
3. **VALIDATE** — Confirm the implementation meets the phase's requirements. Run the mechanical success criteria and the relevant suite as evidence, and verify the behavior actually matches what the phase asked for (green tests that don't encode the requirement don't count). The phase is done only when it conforms.
