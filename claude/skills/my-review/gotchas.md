# Code and Domain Gotchas — my-review

These are durable code, test, and domain traps that warrant targeted scrutiny.
Workflow obligations belong in `references/review-contract.md`, not here.

### Cross-service data structure contracts

When a change stores, extracts, or passes a data structure across services,
trace every consumer. Flag structural divergence such as nested-versus-flat
payloads, different ownership levels, or incompatible field names.

### LLM prompt and tool-docstring changes need evaluation evidence

Prompt, system-message, and tool-docstring changes need a relevant eval or test.
Treat missing coverage as Critical only when the changed behavior is plausibly
launch-critical; otherwise make it a quality finding.

### Shared access helpers need an allowed-path and wrapper-contract test

For a registration decorator, authorization/rollout gate, or injected resolver,
test the successful path as well as denial. Verify authenticated identity and
arguments reach the handler once, its result returns, authorization happens at
the resolver, and required telemetry/session/context wrappers still compose.

### Lazy imports need a demonstrated reason

For Python function-level imports, verify a module-level import actually creates
the claimed cycle or startup-cost problem. Otherwise raise a non-blocking
maintainability finding; a lazy import is not a generic circular-import fix.

### Nested functions need closure state to earn their indirection

Flag a function defined inside business logic unless it is a decorator, fixture,
factory, or otherwise genuinely requires captured state. Prefer a module-level
function when it can be tested and discovered independently.

### User-visible brand names use the established capitalization

For templates, labels, errors, alt text, and other user-facing strings, compare
brand capitalization against nearby established copy and flag inconsistent use.

### Resource labels do not prove workspace ownership

For lifecycle or teardown changes, trace stale, unregistered, and orphaned
resources. A project label, namespace, config lookup, or name prefix alone is
not ownership evidence; persistent provenance must fail closed when absent.

### Host endpoints and internal service health are separate contracts

When code consumes published host ports and validates an internal runtime
network, verify service identity, every published binding, and every consumer
connection string. A healthy container does not prove the host endpoint reaches
the intended service.

### Ambient context and fixtures are runtime dependencies

When a test or command relies on environment, cwd, interpreter, workspace, or
fixture state, verify that setup explicitly. Green local tests can conceal a
different runtime contract in CI or another worktree.

### Test the causal path, not only the final assertion

For cancellation, retries, authorization, or error handling, check that tests
exercise the changed branch and failure mode. A final state assertion alone can
pass while the intended transition never occurs.

### CI wiring and developer instructions are behavioral surfaces

Changes to CI commands, hook scripts, generated instructions, or plugin setup
need tests or direct checks of invocation, arguments, and failure propagation;
they are not documentation-only edits.

### Default-off rollout gates define intended cohort boundaries

For entitlement-gated rollouts, assess enabled-cohort behavior and explicit
policy violations. Do not call the default-off or excluded cohort a defect unless
the stated rollout contract is violated.

### Axon Ecto queries use pipe style

Flag new or modified Axon Ecto queries that use `from(...)` when equivalent
pipe-style composition is practical: `Schema |> join(...) |> where(...) |>
select(...) |> repo.all()`. Treat this as a project code-style requirement;
allow `from` only for documented construct-specific exceptions, and keep test
findings about observable query behavior rather than literal source tokens.
