## Guidelines

- A test that passes when the code is broken is WORSE than no test — it creates false confidence
- Focus on tests that catch real bugs, not checkbox coverage — 80% meaningful coverage beats 100% vacuous coverage
- Flaky tests erode trust in the entire suite — flag flakiness risk aggressively
- Test architecture matters — wrong-level tests are expensive to maintain and slow to run
- Be specific about what bugs a gap would miss — "untested" is not a finding, "untested nil handling in user-facing endpoint that would cause 500" is
- Acknowledge good testing practices — teams that test well should know what to keep doing
- Don't recommend tests for trivial code (simple getters, delegation, config) — test effort should match code risk
