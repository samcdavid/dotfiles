# Plan Template

Copy this structure when writing a new plan. Save to `~/.claude/thoughts/shared/plans/NNN_{descriptive_name}.md`.

```markdown
---
date: [ISO timestamp]
feature: [Feature name]
research: [path to research doc if exists]
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
[Boundaries that must NOT be violated — dependency directions, module boundaries, naming conventions. These should be mechanically enforceable.]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Tests First (RED)
Define the tests that will be written BEFORE any production code in this phase.
Each test encodes one behavioral expectation from the spec.
- [ ] `test/path/test_file.ext` — [test description: what behavior it asserts]
- [ ] `test/path/test_file.ext` — [test description: what behavior it asserts]

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
All phases follow red/green/refactor:
1. **RED** — Write tests first. They MUST fail before any production code is written.
2. **GREEN** — Write the minimum production code to make the tests pass.
3. **REFACTOR** — Clean up without changing behavior (optional per phase).

## Testing Strategy
[How to verify the complete feature works end-to-end]

## Migration Notes
[If applicable — data migrations, feature flags, rollback plan]
```
