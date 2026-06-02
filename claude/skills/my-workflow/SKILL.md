---
name: my-workflow
description: Run my full delivery pipeline end-to-end and autonomously — my-research → my-spec → my-clarify → my-plan → my-observe → my-analyze → my-implement → my-validate → requirements-audit → security-audit → my-arch-review → my-review. Establishes the task once, carries context through every stage, and only stops when a decision genuinely needs a human AND can't be resolved by researching the codebase, Notion, or Google Drive.
disable-model-invocation: true
---

# My Workflow — Full Pipeline, End to End

Orchestrate the complete delivery pipeline as a single autonomous run. The task is established **once** at intake; the context then flows through all twelve stages without re-asking. The pipeline pauses only when it hits a decision that genuinely requires a human and cannot be resolved by more thorough research.

## What this is — and is not

- This skill **runs the real skills in order via the Skill tool**. It does NOT reimplement them. Each stage's skill remains the single source of truth for that stage.
- Contrast with `/my-quick`: that collapses a *subset* of this flow into one fast inline pass for small, well-understood changes. `my-workflow` is the deliberate opposite — every stage runs, in full, for substantial work that deserves the whole pipeline.
- It performs **no outward git actions**. It never commits, pushes, or opens a PR. The hand-off summary is the stopping point.

## Governing constraints (these take precedence over sub-skill instructions)

When a sub-skill's instructions conflict with anything below, **these win**. Read them as hard boundaries, not suggestions.

1. **One intake, then autonomy.** The task/context is captured once in Step 0. After the user gives the go-ahead, run straight through. Do NOT stop at any sub-skill's interactive intake prompt ("Ready to research, what's your question?", "Describe the task…", "Do NOT proceed until confirmed", etc.). Supply the established context as that skill's input and continue. See **The Autonomy Override**.
2. **Research before you ask.** Never bounce a question back to the user that you could have answered yourself. Before any stop, exhaust the **Blocking-Question Protocol**. The only questions that survive are genuine human-judgment calls (product intent, prioritization, an irreversible trade-off) that code, Notion, Google Drive, Linear, and the existing artifacts cannot settle.
3. **No self-approval theatre, no approval gates.** Per the chosen mode, the pipeline is fully autonomous — it does not pause at spec or plan for ceremonial approval. It self-approves its own plan and proceeds to implement. Every autonomous decision and assumption is logged in the ledger and surfaced in the final report for after-the-fact review.
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
| 7 | `my-implement` | approved plan | code changes (TDD red/green/refactor) |
| 8 | `my-validate` | plan + changes | validation report (self-repairs failures) |
| 9 | `requirements-audit` | spec + diff | requirements traceability findings |
| 10 | `security-audit` | diff | security findings |
| 11 | `my-arch-review` | diff | architecture findings |
| 12 | `my-review` | diff vs base branch | code-review findings |

Track these twelve as a TodoWrite list. Mark each `in_progress` when it starts and `completed` when its output exists.

## Step 0 — Intake & entry-point detection (the one upfront confirmation)

This is the **only** planned human touchpoint. Do it well so the rest can run unattended.

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
   > Mode: fully autonomous through all remaining stages; I'll only stop if I hit a decision I genuinely can't resolve from code, Notion, Google Drive, Linear, or the artifacts. No commits/PRs — I'll review the local diff against `[base branch]` and hand off at the end.
   > Assumptions I'm starting with: **[list]**. Anything to correct before I run?

   Wait for the go-ahead **once**. After that, do not seek approval again unless the Blocking-Question Protocol forces it.

5. **Open the ledger.** Create/update `~/.claude/thoughts/shared/workflows/<slug>.md` with: task, base branch, chosen entry point, the stage list with status, and a running "Autonomous decisions & assumptions" section. Update it as each stage completes so the run is resumable and the final report is easy to assemble.

## The Autonomy Override

For **each** stage, invoke its skill with the Skill tool, passing the established context (task + concrete artifact paths/IDs from the ledger) as arguments. Then follow that skill's process **with these adjustments**:

- **Intake prompts → don't stop.** Where the skill says to greet the user, ask "what's the topic", or wait for input, instead supply the answer from the ledger and continue silently.
- **"Do not proceed until confirmed" → confirm via research.** Where a skill gates on user confirmation of a requirements map, spec, or understanding, satisfy that gate yourself: verify against code/Notion/Linear, record the confirmation as an assumption in the ledger, and proceed. Escalate only if the gate hinges on a genuine human-judgment call (see protocol).
- **Interactive question batches (`my-spec`, `my-plan`, `my-clarify`) → filter hard.** Run each candidate question through the Blocking-Question Protocol. Answer everything answerable. Carry the residue — if any survives — into a single batched stop.
- **`my-plan` approval → self-approve.** Generate the plan, sanity-check it against the research/spec, log it as self-approved in the ledger, and move to implement. (Per chosen mode. The plan file still gets written so `my-implement`/`my-validate` have their source of truth.)
- **Don't double-spawn.** Only one stage skill runs at a time. Let each finish before invoking the next.

## Blocking-Question Protocol (research before you ask)

Before EVER stopping to ask the user something, run this in order. You may only stop after all four fail to resolve it:

1. **Re-read the artifacts.** The answer is often already in the research doc, spec, plan, ticket, or earlier in this conversation.
2. **Research the codebase.** Spawn `codebase-locator` / `codebase-analyzer` / `codebase-pattern-finder` to settle questions about how the code actually behaves, what conventions exist, or what's already wired up.
3. **Search Notion, Google Drive + Linear.** Use `notion-search` / `notion-query-data-sources` for design docs, RFCs, and meeting notes; use `Google_Drive__search_files` + `Google_Drive__read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive; fetch linked Linear issues and their comments. Product intent and prior decisions frequently live in one of these — check all three before concluding the answer isn't written down anywhere.
4. **Make a defensible default.** If a competent engineer/TPM could pick a reasonable answer, pick it, log it as an assumption in the ledger, and proceed. A reversible default beats an interruption.

A question survives only if it is **load-bearing** (the outcome changes materially depending on the answer) **and** genuinely **human-judgment** (product priority, intent, an irreversible or expensive trade-off) **and** unresolved by steps 1–4.

**When you do stop**, batch all surviving questions into one message:
> Stopped at **[stage]**. I researched **[code / Notion / Google Drive / Linear / artifacts]** and resolved **[X, Y]** myself. I still need you on: **[the load-bearing questions]** — because **[why each changes the outcome]**.

On the answer, resume from that stage with the new input folded into the ledger. Do not restart from the top.

## Stage notes (where the override needs specifics)

- **2 `my-spec` / 3 `my-clarify`:** These are the most question-prone. Most "questions" are answerable from research + code — resolve them and record assumptions. Feed clarify's resolutions back into the spec file before planning.
- **5 `my-observe`:** It asks which observability platforms/alert channels exist. Detect from the repo first (config files, dependencies, existing dashboards/monitors, CLAUDE.md). If undetectable, default to platform-agnostic recommendations rather than asking. Its output is a companion observability plan linked to the main plan — keep it as a deliverable, not a blocker.
- **7 `my-implement`:** The autonomous code-writing core. TDD red/green/refactor is non-negotiable. Honor its **loop detection**: if the same check fails 3× across attempts, STOP and escalate with the error output and your root-cause theory — that is a genuine blocker, not something to power through.
- **8 `my-validate`:** Run in **Plan Mode** against the plan file from stage 4. Let it self-repair trivial failures; escalate what it cannot fix confidently.
- **Compute the diff once for the review stages.** Detect the base branch and the changed files, then feed both to stages 9–12 so they share one scope:
  ```bash
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
  git diff --name-only "$base"...HEAD
  git diff "$base"...HEAD   # the review scope
  ```
- **9 `requirements-audit`:** Audit the diff against the **stage-2 spec** (and linked Linear ticket) as the source of truth — that satisfies its "requires a spec" gate without asking.
- **10 `security-audit` / 11 `my-arch-review`:** Pass the changed-files list from above as the scope.
- **12 `my-review`:** Run against the base branch so it diffs the current work tree vs `main`/`master` (invoke it with the base branch name). Stay in read-only local review — no checkout, no PR.

## Final report & hand-off

After stage 12, assemble one consolidated report from the ledger:

- **Task & entry point** — what ran, what was skipped and why.
- **Artifacts produced** — paths to research / spec / plan / observability / analysis / validation reports.
- **Autonomous decisions & assumptions** — the full list from the ledger. This is the after-the-fact review surface; make it scannable.
- **Findings by severity** — merge requirements-audit + security-audit + arch-review + my-review, de-duplicated, grouped Critical → Minor.
- **What I changed** — files touched (paths + line counts), tests run + results.
- **Suggested next steps** — `/commit`, then `/create-pr`; and re-run a specific stage if any finding is substantial.

End with the explicit boundary:
> No git actions were taken. This pipeline self-approved its own plan and self-reviewed parts of its own work — treat the findings and assumptions above as the review surface before committing.

## Guidelines

- The intake confirmation is the one place a human is in the loop by design. Everything after is earn-your-interruption: research first, default second, ask last.
- Keep the ledger current. A long run that loses its place wastes the whole pipeline.
- Skipping a stage requires a current artifact that already covers it — never skip to save time.
- Surface assumptions loudly. Autonomy is only safe if every self-made decision is visible afterward.
- A blocker stops the pipeline; it does not get worked around. Escalation is efficiency, not failure.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting. These are known failure patterns — avoid them.
