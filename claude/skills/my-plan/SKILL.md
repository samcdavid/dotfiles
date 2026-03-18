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

## Step 6 — Verification Gate (MANDATORY)

Before presenting the plan, verify:

- [ ] Every file path referenced actually exists
- [ ] Every success criterion is a RUNNABLE COMMAND (no prose-only criteria)
- [ ] Every phase has at least one mechanical success criterion
- [ ] No open questions remain — all resolved or explicitly deferred with rationale
- [ ] "What Could Go Wrong" section exists for each phase
- [ ] Scope boundaries are clear (What We're NOT Doing is populated)
- [ ] Architectural constraints are defined and mechanically enforceable

If any check fails, fix it before presenting to the user.

## Step 7 — Review and Iterate

Present the plan. Incorporate user feedback. Update the saved plan file with changes. The plan is not final until the user approves it.

## Important

- Do NOT write code during planning — only specification
- Success criteria must be MECHANICAL — if a human has to subjectively judge it, rewrite it as something runnable
- Be skeptical of your own assumptions — verify against actual code
- Track all decisions and their rationale

## References

This skill has reference files in `references/` — consult them during planning:
- `references/stack-checklists.md` — per-stack planning considerations
- `references/plan-template.md` — copy-paste plan template

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
