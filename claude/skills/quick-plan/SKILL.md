---
model: opus
name: quick-plan
description: Lightweight conversation-driven planning. Applies a TDD gate per phase — pure refactors get direct-edit phases (no RED/GREEN); behavior-changing fixes get TDD phases. One function per phase regardless. Produces a plan file consumed by quick-implement.
---

# Quick Plan

Create a lightweight plan for a conversation-driven change. Unlike `my-plan`, this skips the full interactive discovery loop — the change is understood from the conversation context. The plan focuses on phasing the work correctly and classifying each phase with the TDD gate.

This skill is typically invoked by `implement-conversation`, which has already run `my-research` and determined the quick pipeline is appropriate.

## Parse Arguments

`$ARGUMENTS` contains the change description and optionally a research artifact path. Read everything provided. Also re-read the conversation context to understand what's being changed and why.

## Step 1 — Read the Target Code

Read every file the change will touch. Stay scoped — don't explore broadly. Check git state to understand what's already in flight:

```bash
git status
git diff HEAD
```

If a research artifact path was passed, read it. Also check `~/.claude/thoughts/shared/research/` for any recent artifact matching this topic.

Spawn a **codebase-pattern-finder** for any function being added or restructured — confirm the codebase doesn't already have a utility doing the same thing. Duplicating existing functionality on a change round is a common rework trigger.

## Step 2 — Inventory the Work

List every function or small unit that needs to change. This is the raw inventory before applying the TDD gate. Be concrete — name specific function signatures, files, and line numbers.

**Hard rule**: one function or one small behavioral unit per phase. Never bundle multiple functions into one phase. If N functions need changing, the plan has N phases.

## Step 3 — Apply the TDD Gate to Each Phase

For each item from Step 2, classify it:

### FULL TDD phase — use when the change:
- Adds new behavior (new function, new edge case, new return shape)
- Fixes a bug (the failing test IS the specification)
- Changes observable behavior that callers would notice
- Can be expressed as: "it should fail this test before the edit, pass it after"

**TDD phase fields:**
- `red_tests` — the test(s) to write first (paths + what each asserts)
- `green_changes` — the production code change (paths + descriptions)
- `success_criteria` — RED: test exists and fails; GREEN: test passes; additional lint/grep checks

### DIRECT EDIT phase — use when the change is:
- Pure restructuring: extracting a helper, inlining a function, reordering clauses — no behavior change
- Pure renaming: variable, function, module — logic unchanged
- Simplification: removing dead code, replacing verbose with concise, no semantic change
- Comment, type annotation, or docstring changes only

**Direct-edit phase fields:**
- `edit_target` — specific file path + function name + line range
- `edit_description` — full description of the edit (enough for an agent with no prior context to execute it precisely)
- `success_criteria` — grep confirms new form exists, lint passes, relevant test suite unchanged

When in doubt, prefer FULL TDD. A refactor that can produce an honest failing test before the edit is a TDD phase, not a direct-edit phase.

## Step 4 — Write the Plan

Save to `~/.claude/thoughts/shared/plans/NNN_quick_{descriptive_name}.md` using 3-digit sequential numbering.

```markdown
---
date: [ISO timestamp]
feature: [change name]
type: quick
status: approved
---

# [Change Name]

## Summary
[One paragraph: what's changing and why]

## Files Touched
- `path/to/file.ext` — [role in this change]

## What We're NOT Doing
[Explicit scope boundaries — what this plan intentionally leaves alone]

---

## Phase 1: [Descriptive Name] — [TDD | DIRECT EDIT]

### Overview
[What this phase accomplishes in one sentence]

### [TDD only] Tests First (RED)
- [ ] `test/path/file.ext` — [what behavior this test asserts, specifically]

### [TDD only] Changes Required (GREEN)
- [ ] `path/to/file.ext` — `function_name` — [what changes]

### [DIRECT EDIT only] Edit Target
- `path/to/file.ext` — `function_name` (lines N–M) — [description of the edit]

### Success Criteria
- [ ] [runnable command — e.g. `mix test test/foo_test.exs`, `grep "new_form" path/to/file.ext`]
- [ ] No lint warnings: [lint command for changed file]

---

## Phase N: ...
```

Proceed immediately after writing the plan — invoking this skill is the approval.
