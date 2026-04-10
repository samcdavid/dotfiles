---
name: my-plan
description: Create a detailed implementation plan with mechanically verifiable success criteria. Interactive and iterative — gathers context, proposes approach, refines with user input. Plans define what TO do, what NOT to do, and how to verify each phase.
disable-model-invocation: true
---

# Create Plan

Create a detailed, verified implementation plan through interactive collaboration. Plans produced by this skill have MECHANICAL success criteria — every phase can be verified by running a command, not just reading prose.

## Getting Started

Respond: "Ready to plan. Describe the task, provide any relevant context, links, or file paths."

Wait for the user's input before proceeding.

## Step 1 — Context Gathering

1. Read ALL mentioned files immediately and FULLY (no limit/offset)
2. Spawn parallel sub-agents:
   - **codebase-locator**: Find all files related to the task
   - **codebase-analyzer**: Analyze current implementation of affected components
   - **codebase-pattern-finder**: Find similar implementations to model after
3. Check for existing research in `~/.claude/thoughts/shared/research/` that's relevant
4. Wait for all sub-agents to complete

Present your informed understanding. Ask focused questions — only things that require HUMAN JUDGMENT (architectural direction, product intent, priorities). Do not ask questions answerable by reading code.

## Step 2 — Research & Discovery

Based on the user's answers:
1. Create a research todo list (TodoWrite) for remaining unknowns
2. Spawn additional research tasks as needed
3. Present findings with design options (pros/cons for each)
4. Let the user choose the approach

## Step 3 — Plan Structure

Propose a phasing structure:
- How many phases
- What each phase accomplishes
- Dependencies between phases
- What's explicitly OUT OF SCOPE

Confirm alignment before writing the full plan.

## Step 4 — Write the Plan

Save to `~/.claude/thoughts/shared/plans/NNN_{descriptive_name}.md` using 3-digit sequential numbering.

Format:
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
[Optional — structural improvements to make after GREEN, without changing behavior. Leave empty if none anticipated.]

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

## Testing Strategy
[How to verify the complete feature works end-to-end]

## TDD Discipline
All phases follow red/green/refactor:
1. **RED** — Write tests first. They MUST fail before any production code is written.
2. **GREEN** — Write the minimum production code to make the tests pass.
3. **REFACTOR** — Clean up without changing behavior (optional per phase).

## Migration Notes
[If applicable — data migrations, feature flags, rollback plan]
```

## Step 5 — Observability Plan (Auto-triggered for product code)

After writing the plan, determine whether an observability plan is needed.

### When to include an observability plan

**YES — create an observability plan** if the changes touch:
- Production-facing code paths (API endpoints, request handlers, controllers)
- Background workers, job queues, or scheduled tasks
- Business logic (domain operations, data transformations, workflow steps)
- LLM agent calls, tool dispatch, or AI pipeline components
- Database operations (queries, migrations that change runtime behavior)
- External integrations (third-party APIs, webhooks, event consumers)
- Any code path a real user or system depends on in production

**NO — skip the observability plan** if the changes are limited to:
- Tests only (`test/`, `spec/`, `*_test.*`, `*.spec.*`)
- Dev tooling or scripts (CI config, Makefiles, shell scripts, seed scripts)
- Documentation or configuration files (no runtime behavior change)
- Dependency version bumps with no code changes
- Linting, formatting, or type annotation fixes
- Internal dev utilities not deployed to production

If the change is mixed (e.g. product code + tests), apply the product code rule — create the observability plan.

### When triggered

Run the `my-observe` skill, passing the current plan file path as context. Save the resulting observability plan to `~/.claude/thoughts/shared/plans/NNNa_{ticket}_observability.md` (same number as the main plan, with `a` suffix) and add `parent_plan: [path to main plan]` to its frontmatter.

---

## Step 6 — Adversarial Challenge (MANDATORY)

Before presenting the plan, spawn the **adversarial-debate** agent to challenge your plan's assumptions and feasibility.

Format the plan's phases, assumptions, and constraints as structured claims and pass them to the agent along with:
- The file paths referenced in each phase
- The success criteria
- The "What Could Go Wrong" sections
- The research doc (if one was used)

The agent will:
- Verify every file path referenced in the plan actually exists
- Challenge assumptions — "you assume this module can be extended, but what if it's intentionally closed or has compile-time constraints?"
- Check for dependency gaps — "phase 2 depends on an assumption from phase 1 that might be wrong"
- Steel-man alternative approaches — "would a simpler approach achieve the same goal?"
- Verify success criteria are truly mechanical (not prose disguised as checks)
- Challenge scope boundaries — "you excluded X, but the implementation will require touching X"

Apply the agent's verdicts — adjust phases, add missing "What Could Go Wrong" items, fix invalid file references, narrow assumptions to what's verified.

After applying verdicts, confirm:
- [ ] Every success criterion is a RUNNABLE COMMAND (no prose-only criteria)
- [ ] Every phase has a "Tests First (RED)" section with at least one test defined
- [ ] Every phase has RED and GREEN success criteria in that order
- [ ] No open questions remain — all resolved or explicitly deferred with rationale
- [ ] Scope boundaries are clear (What We're NOT Doing is populated)
- [ ] Architectural constraints are defined and mechanically enforceable

If any check fails, fix it before presenting to the user.

## Step 7 — Review and Iterate

Present the plan. Incorporate user feedback. Update the saved plan file with changes. The plan is not final until the user approves it.

## Important

- Do NOT write code during planning — only specification
- Every phase MUST define tests before production code changes — TDD is mandatory, not optional
- Success criteria must be MECHANICAL — if a human has to subjectively judge it, rewrite it as something runnable
- Be skeptical of your own assumptions — verify against actual code
- Track all decisions and their rationale

## References

This skill has reference files in `references/` — consult them during planning:
- `references/stack-checklists.md` — per-stack planning considerations
- `references/plan-template.md` — copy-paste plan template

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
