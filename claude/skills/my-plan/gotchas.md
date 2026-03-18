# Gotchas — my-plan

Known failure patterns and lessons learned. Read before starting work with this skill.

### Cross-layer completeness
- **Category:** failure-mode
- **Context:** Planning a fix or feature that touches backend logic
- **Wrong:** Plan addresses only the backend layer where the bug/feature lives
- **Right:** Trace the change through all layers (API → frontend → E2E) and explicitly scope-in or scope-out each layer in the plan
- **Why:** Plans that fix backend logic often miss required UI changes, leading to incomplete implementations that pass backend tests but break the user experience
- **Source:** Recurring pattern in PR reviews

### Cross-service contract alignment
- **Category:** failure-mode
- **Context:** Multiple services handle the same data structure
- **Wrong:** Plan assumes all services agree on data shape without verifying
- **Right:** Verify the contract is identical in all services that touch the data. Check for structural divergence (nested vs flat, field-level vs parent-level storage, nullable vs required)
- **Why:** Structural divergence between services causes subtle bugs that don't surface until integration testing or production
- **Source:** Recurring pattern in polyglot monorepo PRs

### Spec coverage validation
- **Category:** failure-mode
- **Context:** Finalizing a plan for a ticket or spec
- **Wrong:** Plan covers the obvious parts of the spec but misses edge requirements
- **Right:** Before finalizing, enumerate each requirement from the spec/ticket and confirm each has a corresponding phase or is explicitly scoped out with rationale
- **Why:** Partial spec completion is a recurring review finding — plans that seem complete but miss 1-2 acceptance criteria
- **Source:** Recurring pattern in PR reviews
