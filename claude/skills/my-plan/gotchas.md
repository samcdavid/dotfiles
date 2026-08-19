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

### Boy scout rule — don't defer adjacent fixes
- **Category:** convention
- **Context:** Discovering inconsistencies, missing instrumentation, or small bugs in files you're already touching
- **Wrong:** Listing adjacent fixes in "What We're NOT Doing" or deferring to follow-up tickets. Example: finding an inconsistent tag name while adding tracing to the same module, and scoping it out as "not this ticket"
- **Right:** If you find something wrong or inconsistent in code you're already working in, bring it into scope. Only defer things genuinely unrelated to the current files and task. Challenge every item in the "NOT Doing" list — if it's in the same files or directly related, it belongs in the plan.
- **Why:** Deferring small fixes creates tech debt that never gets prioritized. The context is freshest now, and the cost of fixing it is lowest when you're already in the code.
- **Source:** Recurring pattern — adjacent improvements incorrectly scoped out during planning

### Plans and tickets are not verified facts
- **Category:** failure-mode
- **Context:** When a plan references another ticket's work as already done, or when scoping out changes based on reasoning about what another component does
- **Wrong:** Treating plan checkboxes, ticket descriptions, or your own prior claims as ground truth. Example: a plan states "ticket X establishes logging in the dispatcher" — stated confidently because the plan said it was done — but the dispatcher had zero logging code. Similarly, scoping out a function because "it accepts dot notation" sounded right but the actual code lacked the validation that reasoning implied.
- **Right:** Before referencing another ticket's infrastructure or excluding something from scope, read the actual code. A plan saying `[x]` doesn't mean the code exists. A tool "accepting" a parameter doesn't mean it enforces coherence. Verify the mechanism, not just the interface.
- **Why:** Plans describe intent, not state. Code in other branches may not be merged. Claims compound — one unverified assumption becomes the basis for the next conclusion, and by the time you fact-check, multiple decisions are built on sand.
- **Source:** Recurring pattern — plans referencing infrastructure from other tickets that didn't exist yet, and scoping decisions based on surface-level reasoning about code behavior

### Destructive lifecycle commands need resource provenance
- **Category:** failure-mode
- **Context:** Planning local orchestration, cleanup, migrations, cache reset, or any command that stops or deletes named resources
- **Wrong:** Treating a selected project, namespace, config file, or resource-name prefix as proof that existing containers, volumes, or networks belong to the resolved workspace.
- **Right:** Plan a persistent, workspace-derived ownership marker for every resource that can outlive the process/container that created it; verify exact provenance before mutation and fail closed for missing or foreign markers. Include stale, unregistered, and orphaned-resource cases in RED tests.
- **Why:** Configuration uniqueness cannot distinguish a live workspace from a deleted config or earlier implementation. Project-scoped destructive commands can otherwise stop or delete another workspace's state.
- **Source:** ENA-590 PR review — project-only Compose selection could remove stale same-project containers and orphaned volumes.

### Host endpoints are independent contracts
- **Category:** failure-mode
- **Context:** Planning a native process, CLI, test runner, dump/restore command, or browser client that uses host URLs/ports while dependencies run elsewhere
- **Wrong:** Proving only that the selected container/service is healthy, then assuming `localhost:<configured-port>` reaches that same resource.
- **Right:** Trace and validate every host-facing endpoint separately: service identity, published host binding, and consumer connection string. Cover all stateful dependencies a command uses, not just its primary database.
- **Why:** A healthy selected container can coexist with a host port that was changed, reused, or owned by a sibling; the consumer then reaches the wrong stateful service.
- **Source:** ENA-590 PR review — native/test paths required explicit Postgres and Redis endpoint-ownership checks.

### Plan from the effective environment, not one configuration source
- **Category:** failure-mode
- **Context:** Planning tools that combine config files, inherited environment variables, client context files, and generated/subprocess environment
- **Wrong:** Assuming an exported variable is the active setting, or assuming an environment-only guard covers a client whose selection also lives in a config file.
- **Right:** Identify the precedence chain and the effective value at every subprocess boundary. Plan explicit override/sanitization rules and test with conflicting inherited variables and persisted client contexts.
- **Why:** Ambient state makes local tooling silently choose a different daemon, profile, or endpoint than the plan assumes; tests can become machine-dependent.
- **Source:** ENA-590 PR review — Docker context selection and inherited endpoint/profile variables changed behavior outside the parsed worktree config.

### Regression tests must prove the intended path is reached
- **Category:** failure-mode
- **Context:** Planning tests for boundary logic, command entrypoints, configuration splits, or failure paths
- **Wrong:** Adding an assertion that can pass before the relevant code runs, using fixtures that still expose the tool/path being excluded, or using identical values on both sides of a separation.
- **Right:** Specify a RED case with controlled preconditions that reaches the target branch, exercises the public entrypoint, and uses distinguishable values/resources. Assert the prevented side effect did not occur as well as the expected result.
- **Why:** Superficially passing tests routinely miss shebang/entrypoint regressions, prerequisite short-circuits, and accidental fallback to the wrong configuration source.
- **Source:** ENA-590 PR review — restricted-PATH, fixture ordering, and storage-vs-presign regressions.

### Shared access helpers need a complete contract matrix
- **Category:** failure-mode
- **Context:** Planning a shared registration, rollout, authorization, or injected-resolver helper
- **Wrong:** Plan denial/cloaking coverage only, or treat a feature/account gate as the complete authorization boundary.
- **Right:** Plan a test matrix that proves the allowed handler path (identity, arguments, order, exactly-once invocation, result) as well as denial; state that the resolver establishes caller membership/ownership; trace required telemetry, session, and context-wrapper composition.
- **Why:** A gate can reject correctly while silently dropping permitted work, trusting a client-supplied resource ID, or bypassing a platform wrapper before the first real consumer exposes it.
- **Source:** MCP-727 human review

### Typed wrapper seams need lint and static-analysis acceptance criteria
- **Category:** failure-mode
- **Context:** Planning typed `**kwargs` forwarding into library decorators or deep assertions over decoded JSON
- **Wrong:** Use broad `object`/generic mappings and make tests plus formatting the only verification.
- **Right:** Inspect the dependency signature, plan precise forwarded-option and JSON narrowing types, and include focused Ruff *check* and BasedPyright commands.
- **Why:** Passing tests and formatting can conceal type errors that make a reusable wrapper noisy or unsafe to extend.
- **Source:** MCP-727 human review

### Delivery contracts are part of the implementation
- **Category:** failure-mode
- **Context:** Planning new fixtures, command dependencies, CI wiring, or developer documentation for a feature
- **Wrong:** Treating CI filters, tool availability, and instructions as follow-up polish after the code path works locally.
- **Right:** Include CI discovery/fixture materialization, explicit dependency checks, and executable documentation contracts in the same plan. Document which source of configuration the supported CLI reads and every manual endpoint override native consumers require.
- **Why:** A correct local implementation is unavailable or unsafe when CI omits its fixtures, a required binary is implicit, or docs direct users to a configuration channel the CLI ignores.
- **Source:** ENA-590 PR review — RWX fixture filtering, jq dependency checks, and isolated native-mode/profile guidance.
