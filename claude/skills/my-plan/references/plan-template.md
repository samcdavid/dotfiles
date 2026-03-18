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

### Changes Required
- [ ] `file/path.ext` — [specific change description]
- [ ] `file/path.ext` — [specific change description]

### Success Criteria (Mechanical)
Each criterion MUST be a runnable command or verifiable check:
- [ ] `mix test test/path/specific_test.exs` passes
- [ ] `grep -r "pattern" src/` returns expected results
- [ ] `file/path.ext` exports `FunctionName`
- [ ] No new lint warnings: `mix credo --strict`

### What Could Go Wrong
[Anticipated failure modes and mitigations]

## Phase 2: [Descriptive Name]
...

## Testing Strategy
[How to verify the complete feature works end-to-end]

## Migration Notes
[If applicable — data migrations, feature flags, rollback plan]
```
