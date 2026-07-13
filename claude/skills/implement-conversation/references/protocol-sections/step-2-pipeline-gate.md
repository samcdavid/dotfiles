## Step 2 — Pipeline Gate

Based on the research findings and the original request, choose the pipeline:

### Quick Pipeline → `quick-plan` + `quick-implement`

Use when the change is:
- A refactor: restructuring, extraction, inlining, reordering — no behavior change
- A rename: variables, functions, modules — no semantic change  
- A simplification: removing dead code, replacing verbose patterns, improving clarity
- A targeted fix where the affected function is clearly scoped and well-understood
- A cleanup: consistency, unused code removal, formatting

The quick pipeline is appropriate when an experienced engineer could predict the full before/after state without research — the research just confirms the scope.

### Full Pipeline → `my-plan` + `my-implement`

Use when the change:
- Adds new functionality (new function, new endpoint, new module, new behavior path)
- Changes observable behavior that callers depend on in ways that require careful contract analysis
- Fixes a bug requiring a new failing test to formally specify the correct behavior
- Has significant blast radius: many callers, multiple modules, data migrations
- Is architecturally significant: introduces a new pattern, changes a module boundary, adds a dependency

Present the gate decision before running the chosen pipeline:

> Pipeline: **[QUICK | FULL]**
> Reason: [one sentence explaining what drove the choice]
