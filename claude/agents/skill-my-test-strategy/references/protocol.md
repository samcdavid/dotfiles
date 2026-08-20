# Protocol — skill-my-test-strategy

This runner designs the behavior-first TDD strategy that `my-plan` turns into executable RED/GREEN phases. It is not a manual E2E test-plan replacement and it does not write tests or production code.

## Outcome

Produce a durable local artifact at `~/.claude/thoughts/shared/test-strategies/NNN_<topic>.md` that maps each meaningful requirement and regression risk to the smallest test that can prove the observable outcome. The strategy must make implementation tests resistant to harmless refactors and able to catch a realistic behavior regression.

Read the workflow ledger first when one exists. Use its research, clarified spec, and architecture-plan artifacts as the source of truth. Do not re-ask factual questions those artifacts answer. In embedded mode, return only the compact envelope; `my-workflow` owns ledger updates.

## Step 1 — Establish behavior and risk

Read the supplied research, clarified spec, architecture plan, related tests, and relevant production code. Research the testing stack and local conventions before proposing tests. Build a list of:

- Observable user, caller, or operator outcomes from each acceptance criterion.
- Existing behavior that must remain compatible.
- Failure and recovery behavior that a real caller can observe.
- Boundaries that introduce nondeterminism: persistence, time, processes, queues, network calls, randomness, and concurrency.
- Existing tests that already cover a behavior, including whether they are at the right level and have a realistic escape path.

Do not turn private functions, query selection, mock call counts, implementation order, or a framework policy into requirements unless that detail is itself a documented external contract.

## Step 2 — Choose test level and assertion

For each behavior, choose the lowest-level test that can prove the outcome without mocking away the behavior under test:

- **Unit:** pure/domain behavior, validation, branching, and state transitions through a public module/function interface. Assert concrete returned values, emitted domain events, or externally visible state—not collaborators called or queries issued.
- **Integration:** wiring across meaningful boundaries such as HTTP/API → domain → persistence, a worker with its real queue adapter, or a GenServer under its supervisor. Assert the response, persisted state, event, or later public operation that a caller can observe.
- **E2E/manual:** reserve for critical cross-system user journeys; point to `my-test-plan` when a manual execution plan is needed.

Use a test double only at an external or nondeterministic boundary. A double may control time, network response, randomness, or a third-party service; the assertion still proves the system's observable output, persisted postcondition, or published contract. Interaction assertions are allowed only when making that external call with a specific payload is itself the behavior contract; never use them as a substitute for validating the resulting outcome.

Apply these non-negotiable examples:

- A list-producing function or endpoint asserts the returned list's values, filtering, order when specified, and relevant empty/error result. It does not assert that a query ran or that a repository method was called.
- A supervised GenServer failure test drives state through its public API, induces the relevant failure deterministically, then proves the restarted process serves a known-good state through the same public API. It does not assert the supervisor's restart policy, child-start call sequence, or private state mutation unless that policy is the product contract.
- An integration test asserts the user/system result and stable postconditions across the boundary. It does not duplicate unit branching tests or bind itself to controller/service/query call order.

## Step 3 — Design for TDD and stability

For every proposed test, specify the RED behavior it will disprove before production code changes and the observable assertion that will turn GREEN. A test is admissible only if a plausible broken implementation would fail it while a refactor preserving the contract would pass it unchanged.

Specify deterministic controls where relevant: explicit/frozen time, seed data owned by the test, sandboxed persistence, unique process names, controlled message delivery, test servers/fakes at external boundaries, and bounded synchronization rather than sleeps or retry loops. Avoid global mocks, shared mutable fixtures, unbounded polling, random values without a fixed seed, and implicit ordering.

Do not recommend tests for trivial delegation, generated code, or implementation details with no behavior risk. Prefer a smaller set of high-fidelity tests over checkbox coverage.

## Step 4 — Challenge the strategy

Send the behavior matrix and proposed assertion/fixture choices to `adversarial-debate`. Ask it to challenge:

- Whether each assertion would fail for the intended broken behavior.
- Whether a harmless implementation refactor would force a test rewrite.
- Whether unit/integration placement is appropriate and mocks hide the behavior.
- Whether setup has timing, shared-state, ordering, network, or process-lifecycle flakiness.

Apply supported KEEP/REVISE/DROP/PROMOTE verdicts before saving the artifact. Return unresolved testing trade-offs as provisional decisions with options, recommendation, and evidence.

## Artifact format

```markdown
---
date: [ISO timestamp]
feature: [feature/task]
research: [path]
spec: [path]
architecture: [path or none]
status: proposed
---

# Test Strategy: [Feature]

## Test Design Principles
[Behavior-first, implementation-detail exclusions, and local conventions]

## Behavior-to-Test Matrix
| ID | Requirement / risk | Level | Setup/control | Observable assertion | Do not assert | TDD phase |
|---|---|---|---|---|---|---|
| TS-1 | ... | Unit | ... | ... | ... | ... |

## Unit Test Design
[Behavior groupings, public interfaces, edge/failure expectations]

## Integration Test Design
[Boundary flows and stable postconditions]

## Recovery and Concurrency Design
[Known-good recovery state, deterministic synchronization, ownership/cleanup]

## Isolation and Flakiness Controls
[Time, data, process, network, ordering, and fixture controls]

## TDD Handoff to `my-plan`
[One narrow RED behavior per implementation phase, its test ID, expected failing reason, and GREEN outcome]

## Intentional Test Omissions
[Trivial/delegating/generated detail deliberately not tested, with rationale]

## Open Questions / Provisional Decisions
[Only genuine testing trade-offs]
```

## Output envelope

```markdown
status: complete | needs_input | blocked
artifact: { kind: test_strategy, path: <path> }
summary: <behavior coverage and principal test-design decisions>
behavioral_contracts: [<TS-ID: observable behavior>]
plan_amendments: [<required test-first constraint for my-plan>]
assumptions: [<factual assumption>]
provisional_decisions: [{ question, options, recommendation, evidence }]
external_action_requested: null | { actions, targets, rationale }
```
