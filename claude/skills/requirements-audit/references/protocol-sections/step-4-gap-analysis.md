## Step 4 — Gap Analysis

### Missing Requirements
For each "Missing" or "Partial" requirement:
- Is it intentionally deferred? (check PR description, commit messages, comments)
- Is it blocked by something? (dependency, design decision, technical constraint)
- Is it simply overlooked?

### Missing Tests
For each requirement:
- Is there a test that specifically validates this requirement?
- Does the test check the right thing? (not vacuously passing)
- Are edge cases from Step 1 tested?
- Is the test at the right level? (unit for logic, integration for wiring)

### Missing Documentation
- Are user-facing changes reflected in documentation?
- Are API changes reflected in API docs or schemas?
- Are configuration changes documented?

### Regression Test Coverage
Pulled from the **requirements-tracer**'s Test Coverage column. For each `At-risk` finding that survived Step 3:
- If the tracer found `No-test-found` or `Unlikely` → flag as a **Missing test** in Step 6, naming the related issue and the surface that needs coverage.
- If `Likely` → record under "Positive Findings" so it's clear the safety net exists.
