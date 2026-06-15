---
model: opus
name: my-workflow
description: Run my full delivery pipeline end-to-end — my-research → my-spec → my-clarify → my-plan → my-observe → my-analyze → my-implement → my-validate → my-review. Establishes the task once and carries context through every stage. Research and mechanical execution run autonomously; genuine DECISIONS (approach, scope trade-offs, product intent, spec/plan sign-off) belong to the user — the pipeline does all the legwork first, then surfaces the decision instead of making it. The single my-review stage fans out to specialized lens reviewers (security, architecture, performance, QA, requirements), subsuming the former separate audit stages.
disable-model-invocation: true
---

# My Workflow — Full Pipeline, End to End

Orchestrate the complete delivery pipeline as a single run. The task is established **once** at intake; the context then flows through all nine stages without re-asking factual questions. Two things run autonomously — **research** (answering the pipeline's own factual questions) and **mechanical execution** (TDD implementation, validation, review). One thing does not: **genuine decisions stay with the user.** The pipeline never substitutes its own judgment for an approach choice, a scope trade-off, a product-intent call, or sign-off on the spec or plan. It does all the research and preparation so the user decides from a fully-informed position — then it waits for that decision and proceeds.

## What this is — and is not

- This skill **runs the real skills in order via the Skill tool**. It does NOT reimplement them. Each stage's skill remains the single source of truth for that stage.
- Contrast with `/my-quick`: that collapses a *subset* of this flow into one fast inline pass for small, well-understood changes. `my-workflow` is the deliberate opposite — every stage runs, in full, for substantial work that deserves the whole pipeline.
- It performs **no outward git actions**. It never commits, pushes, or opens a PR. The hand-off summary is the stopping point.

## Governing constraints (these take precedence over sub-skill instructions)

When a sub-skill's instructions conflict with anything below, **these win**. Read them as hard boundaries, not suggestions.

1. **One intake, then research autonomy.** The task/context is captured once in Step 0. After the user gives the go-ahead, run straight through the *research and execution* work without re-asking. Do NOT stop at any sub-skill's interactive intake prompt ("Ready to research, what's your question?", "Describe the task…", etc.) — supply the established context and continue. This autonomy covers factual questions and mechanical work; it does NOT extend to decisions (see constraint 3). See **The Autonomy Override**.
2. **Research before you ask.** Never bounce a *factual* question back to the user that you could have answered yourself. Before any stop, exhaust the **Blocking-Question Protocol**. Answer everything code, Notion, Google Drive, Linear, and the existing artifacts can settle — and record it as an assumption in the ledger.
3. **Decisions belong to the user; the pipeline does not decide for them.** The pipeline never substitutes its own judgment for a genuine decision — approach selection, scope trade-offs, product intent, or sign-off on the spec and the plan. It does NOT self-approve its own spec or plan, and it does NOT auto-default a real decision just because a "reasonable" default exists. Instead it researches and prepares fully, then surfaces the decision to the user with its recommendation and the evidence behind it, and waits. What it does autonomously is answer its own *factual* questions (Blocking-Question Protocol) and execute *mechanical* work (TDD implementation, validation, review). Every assumption is logged in the ledger and surfaced in the final report.
4. **No outward actions.** No `git commit`, `git push`, `gh pr create`, or any state-changing remote call. Review stages run against the **local working-tree diff vs the base branch** (`main`/`master`), never a PR.
5. **Carry artifacts forward.** Each stage's output is the next stage's input. Track them in the ledger and pass concrete paths/IDs to each subsequent skill so no stage re-discovers what an earlier one already produced.
6. **A hard failure is a real blocker.** If a stage cannot complete (implement loop-detection trips, validate can't self-repair, a sub-skill errors out), STOP and escalate with full context. Do not skip the stage and march on.

## The pipeline (exact order)

| # | Stage skill | Consumes | Produces |
|---|-------------|----------|----------|
| 1 | `my-research` | task / ticket | research doc in `~/.claude/thoughts/shared/research/` |
| 2 | `my-spec` | research + task | spec in `~/.claude/thoughts/shared/specs/` |
| 3 | `my-clarify` | spec | resolved ambiguities (fed back into the spec) |
| 4 | `my-plan` | spec + research | plan in `~/.claude/thoughts/shared/plans/` |
| 5 | `my-observe` | plan | observability/monitoring design (companion plan) |
| 6 | `my-analyze` | research + spec + plan | cross-artifact consistency report |
| 7 | `my-implement` | approved plan | code changes (per-phase TDD red/green/validate, dispatched to isolated executors) |
| 8 | `my-validate` | plan + changes | validation report (self-repairs failures) |
| 9 | `my-review` | spec + diff vs base branch | consolidated review findings — fans out to security / architecture / performance / QA / requirements / general lens reviewers, then merges, de-dupes, and renders a verdict |
| 9+ | **post-review fix loop** | review findings | repeats `address-pr-feedback` → `my-validate` → `my-review` until the review verdict contains zero blocking and zero non-blocking findings |

Track stages 1–9 as a TodoWrite list. Mark each `in_progress` when it starts and `completed` when its output exists. The post-review fix loop is tracked as a single repeating entry in the ledger (loop iteration count, findings delta per pass).

The single `my-review` stage replaces what used to be four separate stages (`requirements-audit`, `security-audit`, `my-arch-review`, `my-review`): its lens reviewers read those same audit skills' checklists as their source of truth, so running them separately would just duplicate work. The standalone deep audits still exist as skills (`/security-audit`, `/requirements-audit`, `/my-arch-review`, `/perf-review`, `/quality-audit`) — invoke one directly only when a review finding warrants a deeper, opus-level pass on that one lens.

## Step 0 — Intake & entry-point detection (the upfront confirmation)

This is the first human touchpoint and frames the run; the others are the decision points the pipeline reaches along the way (constraint 3). Do this one well so the research and execution between decision points can run unattended.

1. **Establish the task.** Parse `$ARGUMENTS`:
   - Linear issue ID/URL → fetch the issue, its comments, linked issues, and project.
   - File path → read it fully.
   - URL → fetch and extract.
   - Free-text description → use as the task.
   - Empty → **read the conversation context first** (per the "don't ask a blank intake question" pattern). Identify the most likely subject from recent work and propose it. Only ask outright if there's genuinely nothing to go on.

2. **Detect existing artifacts** (so we resume, not redo). In parallel:
   - Search `~/.claude/thoughts/shared/research/`, `/specs/`, and `/plans/` for artifacts matching this task/topic.
   - Check for a prior workflow ledger at `~/.claude/thoughts/shared/workflows/<slug>.md`.
   - If a Linear ticket is in play, note any linked research/spec/plan docs.

3. **Pick the entry stage.** The entry point is the earliest stage whose required input does not yet exist:
   - Plan already exists & current → resume at stage 5 (`my-observe`).
   - Spec exists, no plan → resume at stage 4 (`my-plan`) (run `my-clarify` first only if the spec hasn't been clarified).
   - Research exists, no spec → resume at stage 2 (`my-spec`).
   - Nothing → start at stage 1 (`my-research`).
   - Stages already represented by an existing, current artifact are **skipped** (logged as skipped in the ledger).

4. **Two-translation confirmation.** Present, then proceed on the user's go-ahead:
   > Here's the task as I understand it: **[one paragraph]**.
   > Entry point: **[stage]** — skipping **[stages]** because **[existing artifact / reason]**.
   > Mode: I run research and implementation autonomously, but the **decisions stay yours** — I'll pause for your call on the approach, any scope trade-offs, and sign-off on the spec and the plan, with my recommendation and the evidence already gathered. I won't stop for anything I can resolve from code, Notion, Google Drive, Linear, or the artifacts. No commits/PRs — I'll review the local diff against `[base branch]` and hand off at the end.
   > Assumptions I'm starting with: **[list]**. Anything to correct before I run?

   Wait for the go-ahead **once** to start. After that, do not re-ask *factual* questions — but DO pause at each genuine decision point (per constraint 3 and the Blocking-Question Protocol).

5. **Open the ledger.** Create/update `~/.claude/thoughts/shared/workflows/<slug>.md` with: task, base branch, chosen entry point, the stage list with status, a running "Decisions (made by the user)" section, and a running "Autonomous assumptions (factual, research-resolved)" section. Keep the two separate — decisions are the user's calls, assumptions are facts the pipeline resolved. Update it as each stage completes so the run is resumable, a standalone single-skill run can read it, and the final report is easy to assemble.

## The Autonomy Override

For **each** stage, invoke its skill with the Skill tool, passing the established context (task + concrete artifact paths/IDs from the ledger) as arguments. Then follow that skill's process **with these adjustments**:

- **Intake prompts → don't stop.** Where the skill says to greet the user, ask "what's the topic", or wait for input, instead supply the answer from the ledger and continue silently.
- **Factual confirmation gates → confirm via research.** Where a skill gates on confirming a *factual* claim — a requirements map, a current-state description, "does this code do X" — satisfy that gate yourself: verify against code/Notion/Linear/Drive, record the confirmation as an assumption in the ledger, and proceed.
- **Decision / sign-off gates → surface to the user; do NOT self-approve.** Where a skill gates on a genuine decision (choosing the approach, accepting a scope trade-off, approving the spec, approving the plan), this is the user's call. Do the full legwork first — research, options with pros/cons, and a recommendation — then present it and wait. Never log a decision or plan/spec as "self-approved."
- **Interactive question batches (`my-spec`, `my-plan`, `my-clarify`) → filter hard.** Run each candidate through the Blocking-Question Protocol. Answer every *factual* one from research. Carry the genuine *decisions* into a single batched stop rather than auto-resolving them.
- **`my-plan` approval → the user approves.** Generate the plan, sanity-check it against the research/spec, run its adversarial pass, then present it with your recommendation and wait for the user's approval before implementing. The plan file is written either way so `my-implement`/`my-validate` have their source of truth, but implementation does not start until the user signs off.
- **Don't double-spawn.** Only one stage skill runs at a time. Let each finish before invoking the next.

## Blocking-Question Protocol (research first; then decide who owns it)

Every candidate question is one of two kinds, and they are handled differently:

- A **factual question** has a knowable right answer (how the code behaves, what a ticket says, whether a table exists, what a prior decision was). These you must answer yourself — never bounce them to the user.
- A **decision** is a judgment call with no single right answer (which approach, what scope trade-off, what the product should do, whether the spec/plan is right). These belong to the user.

For every candidate, run this in order:

1. **Re-read the artifacts.** The answer is often already in the research doc, spec, plan, ticket, ledger, or earlier in this conversation.
2. **Research the codebase.** Spawn `codebase-locator` / `codebase-analyzer` / `codebase-pattern-finder` to settle how the code actually behaves, what conventions exist, or what's already wired up.
3. **Search Notion, Google Drive + Linear.** Use `notion-search` / `notion-query-data-sources` for design docs, RFCs, and meeting notes; use `Google_Drive__search_files` + `Google_Drive__read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive; fetch linked Linear issues and their comments. Product intent and prior decisions frequently live in one of these — check all three before concluding the answer isn't written down anywhere.
4. **Classify what remains.**
   - **Factual and now resolved** → log it as an assumption in the ledger and proceed. (A reversible, trivial, non-decision detail — e.g., what to name a private helper — may be defaulted the same way; it is not a decision.)
   - **A genuine decision** → it does NOT get auto-defaulted. Prepare it for the user: the options, the pros/cons, your recommendation, and the evidence you gathered. Carry it to the batched stop.

A question reaches the user only if it is a **genuine decision** that steps 1–3 could not convert into a fact. Decisions are never resolved by "a competent engineer could pick something" — that is exactly the judgment the user reserves.

**When you stop**, batch all surviving decisions into one message:
> Reached a decision point at **[stage]**. I researched **[code / Notion / Google Drive / Linear / artifacts]** and resolved the factual questions (**[X, Y]**, logged as assumptions). I need your decision on: **[the decisions]** — options: **[A vs B]**, my recommendation: **[…]** because **[evidence]**.

On the answer, resume from that stage with the decision folded into the ledger. Do not restart from the top.

## Stage notes (where the override needs specifics)

- **2 `my-spec` / 3 `my-clarify`:** These are the most question-prone. Most "questions" are *factual* and answerable from research + code — resolve those and record assumptions. The residue is usually a genuine scope or product-intent **decision** (what's in scope, what success means, which trade-off) — surface those to the user rather than deciding for them. Feed clarify's resolutions back into the spec file before planning.
- **5 `my-observe`:** It asks which observability platforms/alert channels exist. Detect from the repo first (config files, dependencies, existing dashboards/monitors, CLAUDE.md). If undetectable, default to platform-agnostic recommendations rather than asking. Its output is a companion observability plan linked to the main plan — keep it as a deliverable, not a blocker.
- **7 `my-implement`:** The autonomous code-writing core. It orchestrates the plan one small phase at a time, dispatching each to an isolated `implementation-executor` that does red/green/validate TDD, then re-verifying the result itself. TDD is non-negotiable, and phases must be function-grained — if a plan phase is too big for a single executor, it gets split before dispatch. Honor the orchestrator's **loop detection**: if the same check fails 3× across attempts (executor + re-verify), STOP and escalate with the error output and your root-cause theory — that is a genuine blocker, not something to power through.
- **8 `my-validate`:** Run in **Plan Mode** against the plan file from stage 4. Let it self-repair trivial failures; escalate what it cannot fix confidently.
- **Compute the diff once for the review stage.** Detect the base branch and the changed files, then pass both to `my-review`:
  ```bash
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
  git diff --name-only "$base"...HEAD
  git diff "$base"...HEAD   # the review scope
  ```
- **9 `my-review`:** The single, consolidated review stage. Invoke it with the base branch name so it diffs the current work tree vs `main`/`master`; stay in read-only local review — no checkout, no PR. Because this is the deliberate full pipeline, don't let lens triage thin the review:
  - **Force the full lens set active** — Security, Architecture, Performance, QA, and PM/requirements, plus whichever general lenses (Backend/Frontend/Ops/Migration/Dependency) the diff touches. The pipeline always wants the comprehensive pass, not a minimal triage.
  - **Feed the stage-2 spec as the requirements source.** Pass the spec path so `requirements-reviewer` traces acceptance criteria against the spec (and any linked Linear ticket) — this replaces the former standalone `requirements-audit` stage and satisfies its "requires a spec" need without asking.
  - It internally spawns the research subagents + the per-lens reviewers, then merges, de-dupes, runs the adversarial pass, and proposes a verdict. That single output is the pipeline's complete review surface.

## Post-review fix loop (stage 9+)

After `my-review` produces its verdict, inspect the compiled findings:

- **Converged** — zero blocking (Critical/High) AND zero non-blocking (Medium/Minor) findings: skip the loop entirely and proceed to the final report.
- **Findings remain** — any blocking or non-blocking findings: enter the fix loop.

**Each loop iteration:**

1. **`address-pr-feedback`** — invoke it with the full findings list from the most recent `my-review` run. Pass the review output path/content explicitly so it has the exact findings to address. This skill applies *mechanical* fixes autonomously; treat it the same as `my-implement` under the Autonomy Override. If a finding's fix is a genuine **decision** (a behavior/scope trade-off, not a clear-cut correctness fix), surface it to the user rather than picking for them.
2. **`my-validate`** — run it against the plan file (same as stage 8) to verify the fixes didn't break anything. Let it self-repair trivial failures; escalate what it cannot fix.
3. **`my-review`** — re-run the full review against the same base branch. Force the full lens set again — do not thin the lens set across iterations.

**After each `my-review`**, re-evaluate:
- Zero blocking and zero non-blocking → loop converged, proceed to the final report.
- Still findings → start the next iteration.

**Loop-detection cap:** If after **3 iterations** findings are still non-zero, STOP and escalate:
> Post-review loop did not converge after 3 iterations. Final finding count: **[N]**. Remaining issues: **[list]**. Likely cause: **[root-cause theory]**.

Log each iteration in the ledger: iteration number, findings count going in, findings count coming out, what `address-pr-feedback` changed.

## Final report & hand-off

After the post-review loop converges (or escalates), assemble one consolidated report from the ledger:

- **Task & entry point** — what ran, what was skipped and why.
- **Artifacts produced** — paths to research / spec / plan / observability / analysis / validation reports.
- **Decisions you made** — the decision points where the pipeline paused and what you chose. (These are the user's calls, captured for the record.)
- **Autonomous assumptions** — the full list of *factual* assumptions from the ledger (the things research resolved). This is the after-the-fact review surface; make it scannable. No genuine decision should appear here — decisions live in the section above.
- **Findings by severity** — present the final `my-review` verdict (the pass that converged the loop) grouped Critical → Minor. Note how many loop iterations it took to reach zero findings.
- **What I changed** — files touched (paths + line counts), tests run + results.
- **Suggested next steps** — `/commit`, then `/create-pr`; and re-run a specific stage if any finding is substantial.

End with the explicit boundary:
> No git actions were taken. You approved the spec and plan along the way; the pipeline self-reviewed its own code (the `my-review` stage) — treat the findings and assumptions above as the review surface before committing.

## Guidelines

- The user is in the loop at intake and at every genuine decision point by design. Between those points, run autonomously: research first to answer your own factual questions, then either resolve (factual) or prepare-and-surface (decision). Never ask a factual question you could research; never decide a judgment call the user reserves.
- Earn-your-interruption applies to *factual* questions only — research before asking. It does NOT apply to decisions: those are not interruptions, they are the user's job, and the pipeline's job is to tee them up well.
- Keep the ledger current. A long run that loses its place wastes the whole pipeline.
- Skipping a stage requires a current artifact that already covers it — never skip to save time.
- Surface assumptions loudly. Autonomy is only safe if every factual assumption is visible afterward.
- A blocker stops the pipeline; it does not get worked around. Escalation is efficiency, not failure.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting. These are known failure patterns — avoid them.
