## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Tests First (RED)
Define the tests that will be written BEFORE any production code in this phase.
Each test encodes one behavioral expectation from the spec.
- [ ] `test/path/test_file.ext` — [test description: what behavior it asserts]
- [ ] `test/path/test_file.ext` — [test description: what behavior it asserts]

### Changes Required (GREEN)
Production code changes that make the failing tests pass.
- [ ] `file/path.ext` — [specific change description]
- [ ] `file/path.ext` — [specific change description]

### Refactor Opportunities
[Optional — structural improvements to make after GREEN, without changing behavior. Leave empty if none anticipated.]

### Success Criteria (Mechanical)
Each criterion MUST be a runnable command or verifiable check.
RED criteria run first (tests exist and FAIL), then GREEN criteria (tests PASS):
- [ ] **RED**: Tests in `test/path/test_file.ext` exist and FAIL against current code
- [ ] **GREEN**: `mix test test/path/specific_test.exs` passes after implementation
- [ ] `grep -r "pattern" src/` returns expected results
- [ ] `file/path.ext` exports `FunctionName`
- [ ] No new lint warnings: `mix credo --strict`

### What Could Go Wrong
[Anticipated failure modes and mitigations]
