# Protocol — my-plan

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Create Plan

Create a detailed, verified implementation plan through interactive collaboration. Plans produced by this skill have MECHANICAL success criteria — every phase can be verified by running a command, not just reading prose.

## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`. Before anything else, look for the issue's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by Linear ID, ticket slug, or topic).
- **If one exists, read it fully.** It is the plan-of-record for the whole issue: the task framing, which stages have run, the artifacts they produced (with paths — especially the research doc, spec, and `my-architecture-plan` artifact this plan builds on), and the running "Autonomous decisions & assumptions" list. Treat it as authoritative shared context — consume the linked research, spec, and architecture plan by path rather than re-discovering them, and honor decisions the ledger already records. When an architecture plan exists, its `## Architectural Constraints` section is the source for this plan's own — copy it forward rather than re-deriving constraints from scratch.
- **When you finish, if a ledger exists, append this stage's outcome to it**: the plan path and any assumptions/decisions recorded here.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).

## Getting Started

Determine the task without a blank prompt:
- If `$ARGUMENTS` names a task, ticket, spec, or file paths → use them.
- If empty → read the conversation context, the workflow ledger, and any adjacent spec/research first, then open with a concrete proposal of what you're about to plan.
- Only fall back to "Ready to plan. Describe the task, provide any relevant context, links, or file paths." when there is genuinely nothing to go on.

## Step 1 — Context Gathering

1. Read ALL mentioned files immediately and FULLY (no limit/offset)
2. Research every source before asking the user anything — always answer your own question first. Spawn / search in parallel:
   - **codebase-locator**: Find all files related to the task
   - **codebase-analyzer**: Analyze current implementation of affected components
   - **codebase-pattern-finder**: Find similar implementations to model after
   - **requirements-tracer** (conditional — see triggers below): Map blast radius for intended surfaces, discover related Linear issues, evaluate regression risk on shipped features. Pass `mode: plan`, `scope: wide`, the primary Linear issue ID, and `intended_surfaces` derived from the user's task description.
   - **Linear**: the linked issue, its comments, linked issues, and project, for product intent and prior decisions
   - **Notion**: `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes
   - **Google Drive**: `Google_Drive__search_files` + `read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive
3. Check for existing research/specs in `~/.claude/thoughts/shared/research/` and `/specs/` that's relevant
4. Wait for all sub-agents to complete

Per the **"Plans and tickets are not verified facts"** gotcha: when this step or later phases reference another ticket's work as already shipped, or reason about what a component does based on its interface alone, **read the actual code**. A `[x]` in another plan does not mean the code exists. A function "accepting" a parameter does not mean it enforces coherence. Verify mechanism, not just interface — unverified claims compound.

### When to spawn `requirements-tracer`

Spawn it (in parallel with the other sub-agents) when **either**:

1. **Linear ticket linked** in the task description (Linear URL or issue ID regex match).
2. **User named intended surfaces** in the task description (specific function/module/endpoint/column names — anything concrete enough to grep).

If neither applies (the task is exploratory or the user hasn't named what they'll touch), skip the tracer for this pass and reconsider after Step 2 when intended surfaces are clearer.

In `mode: plan`, the tracer reports test surface presence only — it cannot assess whether tests would catch the regression because the regression form isn't known yet. The git-log heuristic is also skipped (no commits yet).

Present your informed understanding. Ask focused questions — only genuine **decisions** that require HUMAN JUDGMENT (architectural direction, product intent, priorities, irreversible trade-offs). Do not ask questions answerable by reading code, Linear, Notion, or Google Drive — answer those yourself and flag them as assumptions.

## Step 2 — Research & Discovery

Based on the user's answers:
1. Create a research todo list (TodoWrite) for remaining unknowns
2. Spawn additional research tasks as needed
3. Present findings with design options (pros/cons for each) — order options simplest-first, per Simplicity Bias below
4. Let the user choose the approach

### Simplicity Bias (default posture)

When multiple designs satisfy the spec, propose the simplest one by default: fewest new abstractions, fewest new files/modules/services, least new state, most reuse of existing patterns. Complexity — a new abstraction layer, a new service boundary, a new dependency, speculative extensibility for a case the spec doesn't ask for — must be justified by a concrete, already-stated requirement, not "might need it later," "more correct in theory," or "this is how it's usually done." This mirrors the global "don't add abstractions beyond what the task requires" principle, applied specifically to plan authoring.

- Lead the design-options presentation with the simplest viable option, not buried among alternatives.
- If you recommend something more complex than the simplest option, name the specific requirement that rules the simpler one out, and record that trade-off explicitly in the plan (e.g. in `## Overview` or the relevant phase) so the user is approving it knowingly, not inheriting it silently.
- This is a default posture, not an absolute — a genuinely known scale requirement, an explicit non-functional requirement, or a stated future phase in the ticket/spec can justify more structure up front. The bar is a *stated* reason, not a hypothetical one.

## Step 3 — Plan Structure

Propose a phasing structure:
- How many phases
- What each phase accomplishes
- Dependencies between phases
- What's explicitly OUT OF SCOPE

### Phase Sizing — one function at a time (HARD RULE)

Each phase is the smallest unit you'd implement and test in isolation before looking back at the checklist — **typically a single function, method, or one narrow behavior.** Plan the way you'd code by hand: write a test for one function, implement that one function, verify it, then return to the plan for the next. A phase is the right size when:

- It touches **a small, bounded set of files** (ideally one production file + its test).
- It encodes **one behavioral expectation** — one RED test (or a tight cluster) and the minimum GREEN code to satisfy it.
- An implementer who sees **only that phase** — not the whole plan, not the whole repo — could complete it without broad cross-cutting reading. (`my-implement` dispatches each phase to an isolated subagent with a small context budget; an oversized phase blows that budget and gets bounced back for splitting.)

If a unit of work would require touching many files, holding lots of repo context, or bundling several behaviors, **split it into multiple phases.** More small phases is better than fewer large ones — the checklist is meant to be long and granular. Order phases so each depends only on earlier ones (they run sequentially).

Every phase runs the same three subphases: **RED** (write the failing test), **GREEN** (minimum code to pass), **VALIDATE** (run the phase's mechanical success criteria). Plan all three for each phase.

If the **requirements-tracer** ran in Step 1 and surfaced `At-risk` related issues, factor them in:
- Related-issue regression risks shape the `What We're NOT Doing` boundary (e.g., "do NOT alter the return shape of `X` — issue ENG-1234 depends on the current shape").
- Each `At-risk` finding becomes a candidate entry in the relevant phase's `What Could Go Wrong` section.
- Surfaces the tracer flagged as having thin test coverage become candidate entries in the phase's `Tests First (RED)` list — write regression tests for the existing behavior before changing the surface.

Confirm alignment before writing the full plan.

## Step 4 — Write the Plan

Save to `~/.claude/thoughts/shared/plans/NNN_{descriptive_name}.md` using 3-digit sequential numbering.

Format:
```markdown
---
date: [ISO timestamp]
feature: [Feature name]
research: [path to research doc if exists]
architecture: [path to my-architecture-plan artifact if exists]
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
[Explicit scope boundaries — constraints that channel the work. Apply the **"Boy scout rule"** gotcha: if a small fix or inconsistency lives in a file the plan already touches, bring it into scope rather than deferring. Challenge every item here — only genuinely unrelated work belongs on this list.]

## Architectural Constraints
[Boundaries that must NOT be violated — dependency directions, module boundaries, naming conventions. These should be mechanically enforceable. If a `my-architecture-plan` artifact exists for this task, copy its `## Architectural Constraints` section here rather than re-deriving constraints independently.]

## Related-Issue Regression Constraints
[Only if requirements-tracer ran in Step 1 — skip otherwise]
[Contracts and behaviors from shipped issues that this plan must NOT break. Each entry: Linear ID, surface, contract that must be preserved, how to verify.]

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
Every phase is one small unit of behavior (a single function/method where possible) and follows red/green/validate:
1. **RED** — Write the test(s) first. They MUST fail before any production code is written.
2. **GREEN** — Write the minimum production code to make the tests pass (fold in any obvious, behavior-preserving cleanup here).
3. **VALIDATE** — Confirm the implementation meets the phase's requirements. Run the mechanical success criteria and the relevant suite as evidence, and verify the behavior actually matches what the phase asked for (green tests that don't encode the requirement don't count). The phase is done only when it conforms.

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
- The architecture plan (if one was used), especially its Architectural Constraints section — verify this plan's own constraints actually match it rather than silently diverging

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
- [ ] Every phase is small enough for a single implementation subagent — one function / narrow behavior, a bounded file set, no whole-repo reading required. Split any oversized phase before presenting.
- [ ] No open questions remain — all resolved or explicitly deferred with rationale
- [ ] Scope boundaries are clear (What We're NOT Doing is populated)
- [ ] Architectural constraints are defined and mechanically enforceable, and match the `my-architecture-plan` artifact's constraints when one exists

If any check fails, fix it before presenting to the user.

## Step 7 — Review and Iterate

Present the plan. Incorporate user feedback. Update the saved plan file with changes. The plan is not final until the user approves it. Once approved, if a workflow ledger exists for this issue, append the plan path and any logged assumptions to it.

## Important

- Do NOT write code during planning — only specification
- Prefer the simplest design that satisfies the spec — see Simplicity Bias in Step 2; justify any added complexity against a concrete, stated requirement
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
