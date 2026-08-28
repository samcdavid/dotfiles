# Plan Template

Copy this structure when writing a new plan. Save to `~/.claude/thoughts/shared/plans/NNN_{descriptive_name}.md`.

```markdown
---
date: [ISO timestamp]
feature: [Feature name]
research: [path to research doc if exists]
architecture: [path to my-architecture-plan artifact if exists]
test_strategy: [path to my-test-strategy artifact if exists]
status: approved
---

# [Feature/Task Name] Implementation Plan

## Overview
[What we're building and why]

## Current State Analysis
[How things work today, with file:line references]

## Desired End State
[What the system looks like when done]

## What We're NOT Doing
[Explicit scope boundaries — constraints that channel the work]

## Architectural Constraints
[Boundaries that must NOT be violated — dependency directions, module boundaries, naming conventions. These should be mechanically enforceable. If a `my-architecture-plan` artifact exists for this task, copy its `## Architectural Constraints` section here rather than re-deriving constraints independently.]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Tests First (RED)
Define the tests that will be written BEFORE any production code in this phase.
Each test proves one desired outcome from the spec and test strategy—not an
implementation step—and does not duplicate an outcome proved elsewhere.
- [ ] `TS-N` `test/path/test_file.ext` — [public input/setup → expected output or stable postcondition; test level and deterministic control]
- [ ] `TS-N` `test/path/test_file.ext` — [public input/setup → expected output or stable postcondition; test level and deterministic control]

### Changes Required (GREEN)
Production code changes that make the failing tests pass.
- [ ] `file/path.ext` — [specific change description]
- [ ] `file/path.ext` — [specific change description]

### Refactor Opportunities
[Optional — structural improvements to make after GREEN, without changing behavior.]

### Success Criteria (Mechanical)
Each criterion MUST be a runnable command or verifiable check.
RED criteria run first (tests exist and FAIL), then GREEN criteria (tests PASS):
- [ ] **RED**: Tests in `test/path/test_file.ext` exist and FAIL against current code
- [ ] **GREEN**: `mix test test/path/specific_test.exs` passes after implementation
- [ ] `grep -r "pattern" src/` returns expected results
- [ ] `file/path.ext` exports `FunctionName`
- [ ] No new lint warnings: `mix credo --strict`

### What Could Go Wrong
[Anticipated failure modes and mitigations]

## Phase 2: [Descriptive Name]
...

## TDD Discipline
Each phase is one small unit of behavior (a single function/method where possible) and follows red/green/validate:
1. **RED** — Write the test(s) first. They MUST fail before any production code is written.
2. **GREEN** — Write the minimum production code to make the tests pass (fold in any obvious, behavior-preserving cleanup here).
3. **VALIDATE** — Confirm the implementation meets the phase's requirements. Run the mechanical success criteria and the relevant suite as evidence, and verify the behavior actually matches what the phase asked for. The phase is done only when it conforms.

## Testing Strategy
[Link to the `my-test-strategy` artifact. Summarize the unit/integration split, behavior contracts, known-good recovery checks, and isolation/flakiness controls the implementation must preserve.]

## Migration Notes
[If applicable — data migrations, feature flags, rollback plan]
```
