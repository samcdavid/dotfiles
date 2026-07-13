## Step 2 — Analyze the Change

Read the change fully — every file, not just the diff. For PRs, also read the description, linked issues, and any design documents referenced.

Map the change against the existing architecture:

### Structural Fit
- Does the change follow the established module boundaries?
- Are new files placed where the codebase's conventions would expect them?
- Does it follow the existing layering and dependency direction?
- If it introduces a new pattern, is the new pattern better than the established one and worth the inconsistency?

### Coupling Analysis
- Does the change increase coupling between modules that should be independent?
- Are there new cross-boundary imports that bypass the intended dependency direction?
- Does it create hidden coupling? (shared mutable state, implicit contracts, temporal coupling)
- Could a change in one module now break another module that was previously independent?

### Cohesion Analysis
- Are related things grouped together? (high cohesion within modules)
- Does the change scatter a single concern across multiple unrelated modules? (low cohesion)
- Are there functions or files that now have mixed responsibilities?
- Would a future developer know where to find this code based on what it does?

### Boundary Integrity
- Are public interfaces (APIs, exports, contracts) clean and minimal?
- Does the change leak implementation details across boundaries?
- Are service contracts (API schemas, message formats, shared types) backward compatible?
- If this crosses service boundaries, are the contracts explicit and versioned?

### Dependency Health
- Are dependency directions acyclic? (no circular imports between modules)
- Does the change depend on concrete implementations or on abstractions?
- Are third-party dependencies introduced at the right layer? (not deep in domain logic)
- Could this dependency be replaced without rewriting the core logic?
