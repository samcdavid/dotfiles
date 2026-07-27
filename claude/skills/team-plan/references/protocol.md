# Protocol — team-plan

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Team Plan

You are a principal architect coordinating parallel work across a team. Given a Linear milestone, you produce:
1. A per-issue surface analysis — just enough to identify which files and functions each issue will touch
2. A conflict matrix showing where issues overlap
3. A wave-by-wave assignment where each wave can be merged atomically and each developer within a wave works without interfering with others

**Do NOT make any code changes.** Save all artifacts to `~/.claude/thoughts/shared/` and update Linear issues with artifact locations.

## Inputs

`$ARGUMENTS`:
- Linear milestone URL or `project + milestone name` (required)
- Team size (optional — default: 6)

## Hard Constraints

- No code changes, no PRs, no test runs
- No two issues touching the same production files go in the same wave — unless an explicit coordination interface is defined
- Done issues are read-only context; never modify them
- Every wave must be completable and mergeable before the next wave begins
- Update no Linear issues without explicit user confirmation

## Step 1 — Issue Inventory

Fetch all issues in the milestone. Use `list_issues` filtered by milestone; if the list is large, save it and process with `jq`. For each issue, read the full description, comments, and linked issues.

Build a compact inventory:

| ID | Title | Status | Priority | Surfaces Mentioned |
|---|---|---|---|---|

Also read Done issues from the same team — understand what patterns were established and what has already shipped.

Save to `~/.claude/thoughts/shared/plans/NNN_inventory_{milestone_slug}.md`.

**Present the inventory and ask for confirmation before proceeding.** The user may correct priorities or surface details that the ticket descriptions miss.

## Step 2 — Broad Codebase Research

Before diving into individual issues, map the full surface area of the milestone in one pass. Spawn in parallel:
- **codebase-locator**: find all files relevant to the surfaces mentioned across all issues
- **codebase-analyzer**: understand the architecture — how affected modules connect, key interfaces, data models, ownership boundaries
- **codebase-pattern-finder**: find existing patterns for the types of changes these issues require

Synthesize and save to `~/.claude/thoughts/shared/research/NNN_milestone_{milestone_slug}.md`.

Run an **adversarial-debate** agent on any architectural assumptions before proceeding — apply verdicts.

## Step 3 — Per-Issue Surface Analysis

The goal of this step is **conflict detection only** — not full research, spec, or implementation planning. For each issue, answer two questions: which files will be written to, and which functions or data structures will be modified?

Work through all issues in parallel. For each issue, spawn a **codebase-locator** + **codebase-analyzer** pair scoped tightly to that issue:
- Read the issue description and any linked issues
- Find the files that will need to change (use the broad research from Step 2 as a map)
- Identify the specific functions, schemas, or interfaces that will be added or modified
- Note any shared types, contracts, or module boundaries that other issues might also touch

Record a compact surface profile per issue:
```
ENG-123: writes to [user.ex:changeset/2, user_controller.ex:create/2], touches [User schema]
ENG-456: writes to [user.ex:validate/1, auth.ex:sign_in/2], touches [User schema]
```

Do NOT invoke `/my-research`, `/my-spec`, or `/my-plan` here — that depth is for implementation time, not planning time. If a surface cannot be determined from the ticket and codebase locator, note it as "surface unclear — needs ticket refinement" and flag it for the user.

## Step 4 — Conflict Analysis

Using the surface profiles from Step 3, identify every file written to by more than one issue.

Build a conflict matrix:

```
         ENG-1   ENG-2   ENG-3   ENG-4
ENG-1      —     HIGH     —      LOW
ENG-2    HIGH     —      MED      —
ENG-3      —     MED      —      NONE
ENG-4    LOW      —      NONE     —
```

Conflict levels:
- **HIGH**: Both issues write to overlapping functions or structures in the same file
- **MED**: Both touch the same file in distinct sections; additive changes
- **LOW**: Both read the same type/interface without modifying it
- **NONE**: No file overlap

## Step 5 — Wave Assignment

**Single developer (`team_size == 1`):** skip this step. Waves exist to prevent two developers colliding, which cannot happen here. Emit a critical-path sequence instead — issues in dependency order, with prerequisites and the coordination interfaces that still matter because they cross issue boundaries in time rather than between people.

Group issues into waves. Hard rules:
- Max `team_size` issues per wave (default 6)
- No two HIGH-conflict issues in the same wave
- Each issue in a wave is one developer's solo work — they own it atomically

Preferred (override when needed):
- Prefer grouping by architectural layer across waves (data-layer changes before API changes before feature work)
- Issues that establish shared interfaces go in the earliest possible wave

For any HIGH-conflict pair that must share a wave, define a **coordination interface**: a shared type, function, or contract both issues agree on before either starts. Add this as a Phase 0 in both plans.

Document the assignment:
```
Wave 1: [ENG-1, ENG-3, ENG-7, ENG-9] — all merge independently before Wave 2 begins
  Coordination note: ENG-1 and ENG-3 both extend UserParams; ENG-1 lands first per slot ordering
Wave 2: ...
```

## Step 6 — Regression Risk Annotations

Using the conflict matrix, identify the tests most likely to break when issues from the same wave (or adjacent waves) merge. For each HIGH or MED conflict pair, note what the implementer of one issue should watch for when the other lands:

```markdown
### ENG-123 × ENG-456 (HIGH — shared: user.ex:changeset/2)
- ENG-123 implementer: re-run user creation tests after ENG-456 merges
- ENG-456 implementer: if you change changeset/2's return shape, ENG-123's tests will fail

### ENG-789 × ENG-234 (MED — shared: router.ex)
- Both add routes in the same section; merge order matters, verify no duplicate paths
```

Save to `~/.claude/thoughts/shared/plans/NNN_regression_risks_{milestone_slug}.md`.

## Step 7 — Linear Updates

For each issue, prepare a comment containing:
- Wave number and developer slot
- Surface profile (which files/functions it will touch)
- Known HIGH/MED conflict risks with other milestone issues
- Link to the master plan and regression risk docs

Confirm with the user: "I'll add artifact links as comments on [N] Linear issues. Proceed?"

Then write the comments using `save_comment`.

## Step 8 — Master Coordination Plan

Save to `~/.claude/thoughts/shared/plans/NNN_team_plan_{milestone_slug}.md`:

```markdown
---
date: [ISO timestamp]
milestone: [name]
team_size: [N]
issues: [count]
waves: [count]
status: ready
---

# Team Plan: [Milestone Name]

## Summary
[Issue count, wave count, key architectural concerns, critical dependency chain]

## Wave Breakdown

### Wave 1
| Slot | Issue | Plan | Notes |
|-----|------|------|-------|
| 1 | ENG-1 | plans/015_... | |
...

### Wave 2
...

## Conflict Matrix
[Full matrix from Step 4]

## Coordination Interfaces
[Shared types/functions/contracts Wave N issues must agree on before parallel work begins]

## Surface Profiles
| Issue | Files Written | Functions/Structures Modified |
|------|-------------|-------------------------------|
| ENG-1 | user.ex, router.ex | changeset/2, POST /users |
...

## Regression Risk Summary
See: plans/NNN_regression_risks_{milestone_slug}.md
```

Present the master plan as the final deliverable and ask: "What's wrong or missing?"

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work.
