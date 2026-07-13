## Step 3 — Cross-Reference Matrix

Compare every commitment against every other artifact. Look for:

### 3a. Contradictions
Artifacts that directly disagree:
- Spec says X, plan does Y
- Research found behavior A, but spec assumes behavior B
- Plan targets file/component that research identified as deprecated or problematic

### 3b. Coverage Gaps
Requirements or findings with no downstream coverage:
- Spec requirement with no corresponding plan phase or success criterion
- Research risk with no mitigation in the plan
- Research open question that the spec or plan silently resolved (or silently ignored)

### 3c. Scope Drift
The plan does more or less than the spec asks for:
- Plan phases that implement things not in the spec (scope creep)
- Spec requirements that no plan phase addresses (dropped requirements)
- Plan's "What We're NOT Doing" that contradicts the spec's "Included" scope

### 3d. Assumption Divergence
Artifacts that assume different things about the world:
- Spec assumes a service exists; research shows it doesn't
- Plan assumes a specific data model; research describes a different one
- Spec assumes a constraint; plan ignores it

### 3e. Staleness
Research findings that may have been invalidated since the research was conducted:
- Research references code paths that the plan modifies — are the findings still valid post-change?
- Research was conducted before spec was finalized — does it answer the right questions?
