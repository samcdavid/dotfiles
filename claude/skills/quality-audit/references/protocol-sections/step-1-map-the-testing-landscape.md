## Step 1 — Map the Testing Landscape

Spawn parallel agents:
- **codebase-locator**: Find all test files related to the audit scope, plus the production code they cover
- **codebase-analyzer**: Trace the code paths in the changed/target production code — branches, error paths, external calls, state transitions
- **codebase-pattern-finder**: Identify the project's testing conventions — test organization, factory patterns, helper usage, mock strategy, assertion style

Identify:
- All production code paths that should be tested (happy path, error paths, edge cases, boundary conditions)
- All existing tests that exercise the target code (direct and indirect)
- The testing stack (framework, assertion library, factory/fixture approach, mock/stub tools)
- Test organization conventions (file placement, describe/context structure, naming)
