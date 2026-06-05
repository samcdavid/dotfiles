---
model: opus
name: implement-conversation
description: Conversation-to-code pipeline for changes described in chat. Runs my-research → pipeline gate → quick-plan/quick-implement (for refactors and targeted fixes) or my-plan/my-implement (for new behavior and complex changes) → my-review. Autonomous after intake.
disable-model-invocation: true
---

# Implement Conversation

Turn a conversational change request into implemented, reviewed code. This skill runs the right-sized pipeline for the change — research, plan, implement, review — without the full 9-stage delivery overhead of `my-workflow`.

**When to use this vs. `my-workflow`:** Use this skill when you've described what you want in chat — a targeted fix, refactor, rename, cleanup, or small addition — and want it executed rigorously rather than one-shot inline. Use `my-workflow` for substantial feature delivery that warrants spec, clarify, observe, analyze, and validate stages.

## Getting Started

Parse `$ARGUMENTS`:
- Change description → use as the task
- File paths → read them; the task is "change these files as discussed in the conversation"
- Empty → read the conversation context; propose the most recent change topic

Do NOT ask a blank intake question. The conversation already contains the task.

## Step 0 — Intake (the one upfront touchpoint)

Read the conversation and state your understanding:

> Here's the change as I understand it: **[one paragraph]**.
> I'll research first, then decide between the quick pipeline (refactor/cleanup) or the full pipeline (new behavior/complex change).
> No commits or pushes — the pipeline stops after review. Anything to correct?

Proceed after acknowledgment. This is the only planned human touchpoint.

## Step 1 — Research

Invoke `my-research`. Supply the change as the research question and pass any file paths mentioned in the conversation as explicit context so the research stays scoped — this is not a broad exploratory pass; it is a targeted read of the code being changed plus its immediate dependencies.

After research completes, note the artifact path.

## Step 2 — Pipeline Gate

Based on the research findings and the original request, choose the pipeline:

### Quick Pipeline → `quick-plan` + `quick-implement`

Use when the change is:
- A refactor: restructuring, extraction, inlining, reordering — no behavior change
- A rename: variables, functions, modules — no semantic change  
- A simplification: removing dead code, replacing verbose patterns, improving clarity
- A targeted fix where the affected function is clearly scoped and well-understood
- A cleanup: consistency, unused code removal, formatting

The quick pipeline is appropriate when an experienced engineer could predict the full before/after state without research — the research just confirms the scope.

### Full Pipeline → `my-plan` + `my-implement`

Use when the change:
- Adds new functionality (new function, new endpoint, new module, new behavior path)
- Changes observable behavior that callers depend on in ways that require careful contract analysis
- Fixes a bug requiring a new failing test to formally specify the correct behavior
- Has significant blast radius: many callers, multiple modules, data migrations
- Is architecturally significant: introduces a new pattern, changes a module boundary, adds a dependency

Present the gate decision before running the chosen pipeline:

> Pipeline: **[QUICK | FULL]**
> Reason: [one sentence explaining what drove the choice]

## Step 3 — Plan

**Quick pipeline:** Invoke `quick-plan` with the task description and the research artifact path. It will inventory the work function-by-function, apply the TDD gate per phase (TDD for behavior changes, direct-edit for pure refactors), and write a plan file. Proceed immediately — `quick-plan` is self-approving.

**Full pipeline:** Invoke `my-plan` with the task description and the research artifact path. Follow its full process. Self-approve the plan (this is an autonomous pipeline — no additional confirmation is needed after the Step 0 touchpoint). Record the plan file path in the ledger.

## Step 4 — Implement

**Quick pipeline:** Invoke `quick-implement` with the plan file path. It dispatches each phase to `quick-implement-agent` — TDD phases follow RED → GREEN → VALIDATE; direct-edit phases follow READ → EDIT → VALIDATE. The SubagentStop hook fires on every agent stop (format + lint + changed tests).

**Full pipeline:** Invoke `my-implement` with the plan file path. It dispatches each phase to `implementation-executor` using strict RED → GREEN → VALIDATE TDD. The same SubagentStop hook fires.

Both paths use the same re-verify discipline: the orchestrator re-runs each phase's success criteria independently and checks requirements conformance before advancing. Neither path commits anything.

If a phase fails loop detection (same failure 3×), STOP and present the blocker to the user. Do not power through a 3-strike failure.

## Step 5 — Review

Compute the diff scope:

```bash
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
[ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
git diff --name-only "$base"...HEAD
```

Invoke `my-review` with the base branch name. Stay in local mode — no checkout, no PR. Let `my-review` do its own lens triage based on what the diff actually touches.

## Final Report

After Step 5, assemble a brief report:

- **Pipeline used**: QUICK or FULL, and why
- **Research artifact**: path
- **Plan artifact**: path
- **What changed**: files touched, phases executed, re-dispatches needed
- **Review findings**: `my-review`'s compiled output (Critical → Minor)
- **Autonomous decisions**: any choices made during planning/implementation not derived from explicit user instructions

End with:
> No git actions were taken. Use `/commit` when ready to commit.

## Governing Constraints

1. **No outward actions.** No `git commit`, `git push`, `gh` state-changing calls. The pipeline produces working-tree changes only.
2. **Autonomous after intake.** After Step 0, run straight through. Sub-skills that ask for interactive input should be supplied the established context and not allowed to re-ask.
3. **Research before asking.** Any question answerable from code or conversation context is not a valid stopping point. Apply the same Blocking-Question Protocol as `my-workflow`.
4. **One intake, then carry context forward.** Never re-ask what was established in Step 0.
5. **A hard failure is a real blocker.** If a stage cannot complete (loop detection trips, a sub-skill errors out), STOP and escalate. Do not skip the stage.
