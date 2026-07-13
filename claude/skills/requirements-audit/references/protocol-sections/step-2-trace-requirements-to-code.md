## Step 2 — Trace Requirements to Code

For each requirement in the map:

### Code Mapping
Spawn parallel agents:
- **codebase-analyzer**: Read every changed file fully. For each requirement, identify the specific file(s), function(s), and line(s) that implement it.
- **codebase-pattern-finder**: Check how similar requirements were implemented elsewhere — is this implementation consistent with precedent?
- **requirements-tracer** (`mode: review`, `scope: wide`): Map blast radius for the diff, discover related Linear issues, evaluate regression risk on shipped features, and assess test coverage on at-risk surfaces. Pass the primary Linear issue ID and the PR number. Its output feeds Step 3 (Related-Issue Regression) and Step 4 (Regression Test Coverage).

Build a traceability matrix:

```markdown
| Requirement | Status | Implementing Code | Test Coverage | Notes |
|------------|--------|------------------|--------------|-------|
| R1 | Covered / Partial / Missing / Excess | `file:line` — [function] | `test_file:line` | [gaps or concerns] |
```

Statuses:
- **Covered** — requirement is fully implemented and tested
- **Partial** — some aspects implemented, others missing
- **Missing** — no corresponding code change found
- **Excess** — code exists that doesn't trace to any requirement (potential scope creep)

### Behavior Verification
For each "Covered" requirement, verify the implementation actually produces the specified behavior:
- Read the code path end-to-end — from user action to system response
- Check that the happy path matches the spec exactly (not approximately)
- Check that error/edge case paths produce reasonable behavior (even if not specified)
- Verify that the user-facing output (UI text, API response shape, email content) matches any design specs

### Edge Case Verification
For each implicit edge case identified in Step 1:
- Is it handled in the code?
- If handled, is the behavior reasonable?
- If not handled, could it cause a failure, data corruption, or confusing UX?
