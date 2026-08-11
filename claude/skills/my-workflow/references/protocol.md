# Protocol — my-workflow

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## My Workflow

Orchestrate the delivery pipeline as resumable stage work. The task is established once at intake, artifacts carry context between stages, and the workflow ledger is the resume source of truth.

Stages 1-8 run back-to-back with no stop between them; the ledger is updated silently after each one. Genuine decisions inside a stage are resolved with the pipeline's own best recommendation and logged as provisional rather than asked live. The pipeline stops after stage 8 — the **Decisions Checkpoint** — to present every artifact and every provisional decision together, so the user can confirm or override. This is the deliberate point to clear context: the next run reads the ledger and resumes from here.

Stage 9, the pre-implementation coordination check, runs only after the user resumes past the Decisions Checkpoint — never before it, and never folded into it. It stops on its own only if it finds a sibling overlap; when clear, it flows straight into the atomic execution/review block with no further stop: `my-implement`, then the automatic fix loop (`my-validate` -> `my-review` -> `address-pr-feedback local`, repeating until clean or 3 iterations), without stopping between them, ending at one stop after the final review output. Implementation cannot start from a new workflow or loose artifacts; it requires completed ledger status for all prior stages, user confirmation of every provisional decision at the Decisions Checkpoint, and a fresh `passed` pre-implementation coordination check run after that confirmation.

Factual questions are handled autonomously through research. Genuine decisions are also resolved autonomously with the pipeline's best recommendation and logged as provisional — ownership stays with the user, who confirms or overrides every provisional decision at the Decisions Checkpoint before the pre-implementation coordination check or implementation can start.

## What this is — and is not

- This skill **runs the real skills in order via the Skill tool**. It does NOT reimplement them. Each stage's skill remains the single source of truth for that stage.
- Contrast with `/my-quick`: that collapses a *subset* of this flow into one fast inline pass for small, well-understood changes. `my-workflow` is the deliberate opposite for substantial work. If intake routes to `my-quick`, record that route and reason in the workflow ledger before handing off.
- It commits locally as work lands — each validated phase and fix gets its own commit via the `commit` skill — but performs **no remote git actions**. It never pushes or opens a PR. The hand-off summary is the stopping point.

## Governing Constraints

These override sub-skill instructions.

1. **One intake, one Decisions Checkpoint.** Capture task/context once in Step 0. After go-ahead, run stages 1 through 8 autonomously and back-to-back, updating the ledger silently after each one. Do not stop between stages 1-8 for user review — the only guaranteed stop before the atomic block is the Decisions Checkpoint after stage 8.
2. **Resume from artifacts.** On a later run, read the ledger and continue from the earliest incomplete stage. Do not redo completed stage work unless its input artifact changed.
3. **Research before asking factual questions.** Answer knowable questions from code, Notion, Google Drive, Linear, and artifacts; log factual assumptions in the ledger.
4. **Decisions belong to the user, but the pipeline doesn't stop mid-run to ask.** Approach selection, scope trade-offs, product intent, and spec/plan approval are user decisions. Prepare evidence and a recommendation, pick the recommendation, log it under the ledger's `## Provisional Decisions` section, and continue. Every provisional decision from stages 1-8 is presented together at the Decisions Checkpoint for the user to confirm or override before the pre-implementation coordination check or implementation starts.
5. **Pre-implementation check runs after the Decisions Checkpoint, never before.** Stage 9 only starts once the user has resumed past the Decisions Checkpoint with every provisional decision confirmed or overridden. It is a fresh check, not something to run speculatively during stages 1-8 or to fold into the Decisions Checkpoint's own output.
6. **Atomic execution/review block.** Implementation is gated. Start it only when the ledger explicitly marks stages 1-8 complete, every provisional decision confirmed/overridden at the Decisions Checkpoint, and the pre-implementation coordination check `passed` for the current plan version (run fresh after that checkpoint). Once implementation starts, run `my-implement`, then the automatic fix loop, without stopping between them. Stop after the final review output.
7. **Fix loop runs unattended.** After `my-implement`, loop `my-validate` -> `my-review` -> `address-pr-feedback local` until a review pass is clean of Critical and substantive non-blocking findings, capped at 3 iterations. No checkpoint between iterations; stop once after the final review. Nits never trigger another iteration.
8. **No remote actions.** Local commits per validated phase/fix are expected. No `git push`, `gh pr create`, published replies, or state-changing remote calls unless explicitly requested.
9. **Carry artifacts forward.** Each stage's output is the next stage's input. Track concrete paths/IDs in the ledger.
10. **Cross-workflow coordination runs at intake, the pre-implementation gate, and the final atomic checkpoint.** When the task is a Linear issue, re-run `references/cross-workflow-coordination.md` at Step 0 intake, at stage 9's Pre-Implementation Gate (after the Decisions Checkpoint), and once more at the atomic block's own final checkpoint after review — sibling ledgers and sibling issues can change between those points. Log a note when siblings are clear; escalate to the user only on an actual file/module or requirement/scope overlap, per that reference's escalation bar. An overlap found at stage 9 is its own stop, separate from the Decisions Checkpoint that already ran.
11. **Provisional decisions are logged, never silently resolved.** Whenever a stage reaches a genuine decision, research it, form a recommendation, pick it, and record it under the ledger's `## Provisional Decisions` section (stage, question, options, recommendation chosen, evidence) before continuing to the next stage. A provisional decision is not a factual assumption — it must be confirmed or overridden by the user at the checkpoint, even when the recommendation seems obvious.

## Pipeline Exact Order

| # | Stage | Consumes | Produces | Checkpoint |
|---|---|---|---|---|
| 1 | `my-research` | task / ticket | research doc | continue |
| 2 | `my-spec` | research + task | spec | continue |
| 3 | `my-clarify` | spec | clarified spec | continue |
| 4 | `my-architecture-plan` | clarified spec + research | architecture plan | continue |
| 5 | `my-plan` | spec + research + architecture plan | plan | continue |
| 6 | `my-observe` | plan | observability companion | continue |
| 7 | `my-eval-plan` (conditional) | plan | eval companion | continue |
| 8 | `my-analyze` | research + spec + plan + companions | consistency report | **stop — Decisions Checkpoint** |
| 9 | Pre-implementation coordination check (Linear issues only), run after the Decisions Checkpoint is confirmed | finalized plan + fresh sibling ledger/issue scan | updated `cross_workflow` ledger section | stop only if overlap found |
| 10-12 | gated atomic block: `my-implement` -> automatic fix loop | approved plan + confirmed provisional decisions + completed stage 1-9 ledger | commits per phase, validation report, review verdict | stop after final review |
| loop | `my-validate` -> `my-review` -> `address-pr-feedback local`, max 3 iterations | review findings | fix commits, validation, new review verdict | no stop between iterations |

Every stage still writes to the ledger the moment it finishes — status, artifacts, and any provisional decision. Stage 8's Decisions Checkpoint is the mandatory stop and the intended point to clear context; stage 9 only stops again if it surfaces a sibling overlap, and otherwise flows straight into the atomic block. Track stages in the ledger. Mark each `in_progress` when it starts and `completed` when output exists. A checkpoint is an intentional stop, not a blocker.

Stage 7 is conditional. Run `my-eval-plan` when the plan touches an AI/LLM surface — prompts, system messages, tool docstrings, model or retrieval selection, scoring, or any behavior a model produces. Otherwise mark it `not_applicable` in the ledger with a one-line reason. `not_applicable` satisfies the implementation gate; an unset stage does not.

The single `my-review` stage replaces separate `requirements-audit`, `security-audit`, `my-arch-review`, `perf-review`, and `quality-audit` runs; lens reviewers read those skills' criteria as source truth. Invoke a standalone deep audit only when the review finding warrants a focused follow-up.

## Step 0 - Intake & Entry-Point Detection

This first human touchpoint frames the workflow and creates or updates the ledger.

1. **Detect the workflow ledger first, keyed to the current branch.** Run `git branch --show-current` before matching by anything else, then search `~/.claude/thoughts/shared/workflows/`:
   - **Feature branch:** a ledger whose `branch` field matches is the ledger, full stop. Resume it and use its recorded task — no confirmation needed, even if this invocation's arguments are phrased differently. There is exactly one ledger per branch; never create a second one for a branch that already has one. The only way to start a new ledger on a branch that has one is the user explicitly saying to abandon or replace the existing one.
   - **Default branch (`main`/`master`) or no branch match:** fall back to matching by Linear ID, ticket slug, or topic — several ledgers can legitimately sit on the default branch before their feature branch exists, so branch alone doesn't disambiguate there.
   - **No match by either key:** this is a new workflow; the current branch gets recorded on it in Step 6.
   Then search research, specs, and plans only to attach artifact paths to ledger stages. Artifacts do not mark stages complete by themselves.
2. **Establish task.** Parse `$ARGUMENTS`, unless Step 1 already resolved the task from a branch-matched ledger:
   - Linear issue ID/URL -> fetch issue, comments, linked issues, project.
   - File path -> read fully.
   - URL -> fetch/extract.
   - Free-text description -> use task.
   - Empty -> read conversation context first; ask only if there is genuinely no target.
3. **Choose full pipeline or quick handoff.** Use `references/stage-routing.md`. If no ledger exists and the work is not explicitly routed to `my-quick`, the entry stage is always `my-research`.
   - If routing to `my-quick`, open the workflow ledger first and record `route: my-quick`, reason, expected scope, skipped full-pipeline rationale, and exact handoff command.
   - Then present the handoff upfront instead of pretending the full pipeline started.
4. **Cross-workflow coordination.** If the task resolves to a Linear issue, run `references/cross-workflow-coordination.md` now: resolve the issue's project/milestone, scan sibling ledgers and live Linear sibling issues, and check for file/module or requirement overlap. Fold the result into the confirm-mode message below — either "no sibling overlap found" or the overlap decision to raise.
5. **Confirm mode once.** Present:

```markdown
Here's the task as I understand it: **[one paragraph]**.
Entry point: **[stage]**; skipped stages: **[only stages already completed in the ledger, with artifact paths]**.
Route: **[full pipeline | my-quick, with ledgered reason]**.
Cross-workflow: **[no Linear issue | siblings checked and clear | overlap found — see decision below]**.

Mode: I run research through analysis back-to-back with no stops in between. Factual questions are researched as they come up. Genuine decisions (approach, scope, architecture trade-offs, spec/plan sign-off) get my own best recommendation, logged as a provisional decision rather than asked live. I stop once, after analysis — the Decisions Checkpoint — to hand you every artifact and every provisional decision together for confirmation or override; that's also the point to clear context if you want to. Only after you resume past that checkpoint do I run the pre-implementation coordination check, which stops again only if it finds a sibling overlap — otherwise it flows straight into `my-implement` plus the automatic fix loop (`my-validate` -> `my-review` -> `address-pr-feedback local`, up to 3 passes). Each validated phase and fix is committed locally so the session leaves a readable history; no pushes, PRs, or other outward actions unless explicitly requested. When the task shares a Linear project or milestone with other in-progress work, I check for sibling overlap at intake and again at the pre-implementation gate after your confirmation.

Starting assumptions: **[list]**.
```

Wait for go-ahead once to start the selected stage.

6. **Open ledger.** Create/update `~/.claude/thoughts/shared/workflows/<slug>.md` with task, `branch` (the current git branch — the primary lookup key for future invocations per Step 1), `base_branch` (the diff target for review, usually `main`/`master`), chosen entry point, route, stage statuses, artifact paths, decisions, autonomous assumptions, and (when applicable) the `cross_workflow` section from `references/cross-workflow-coordination.md`. New full-pipeline ledgers start with all stages incomplete. Quick-handoff ledgers record the route and handoff command instead of stage completion. Update it at every checkpoint; if the branch changes mid-workflow (renamed, or moved intentionally), update `branch` too rather than leaving it stale.

## Autonomy Override

For the selected stage, invoke the stage skill with established context: task plus concrete artifact paths/IDs from the ledger. Then follow that skill with these adjustments:

- **Intake prompts stay internal.** If the stage skill asks for topic/context, provide it from the ledger and continue within the stage.
- **Factual gates are researched.** If the stage asks to confirm how code behaves, what requirements say, or whether wiring exists, verify through code/docs/tickets/artifacts and log the factual assumption.
- **Decision gates get a recommendation and continue.** If the stage reaches approach choice, scope trade-off, product intent, or spec/plan approval, research it, prepare options and a recommendation, pick the recommendation, log it as a provisional decision in the ledger, and keep running the pipeline. Do not stop the stage for it — it surfaces later at the Decisions Checkpoint.
- **Provisional decisions accumulate instead of batching into a per-stage stop.** For `my-spec`, `my-clarify`, `my-architecture-plan`, and `my-plan`, run every question through the Blocking-Question Protocol: factual questions get resolved and logged as assumptions; genuine decisions get a recommendation, get logged as provisional, and the stage continues.
- **Plan approval is provisional like any other decision gate.** The plan is written and a recommendation logged, but the pipeline does not stop for it — it surfaces at the Decisions Checkpoint alongside every other provisional decision, and the pre-implementation coordination check (stage 9) cannot start until the user confirms there and the ledger marks stages 1-7 complete.
- **Stage boundary is soft between 1-8, hard at 8->9.** Move directly from one completed stage to the next without stopping. The guaranteed stop is once after stage 8 (the Decisions Checkpoint); stage 9 stops again only on a sibling overlap, and the atomic block (`my-implement` plus the fix loop) stops once more when it completes.
- **Do not double-spawn.** Only one stage skill runs at a time.

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
   - **A genuine decision** → it does NOT get silently defaulted, and it does NOT stop the stage. Prepare it fully: the options, the pros/cons, your recommendation, and the evidence you gathered. Pick the recommendation, log it under the ledger's `## Provisional Decisions` section (stage, question, options, recommendation chosen, evidence), and continue running the pipeline.

A genuine decision is never resolved by "a competent engineer could pick something" without recording it — even an obvious call must be logged as provisional. The distinction from a factual assumption is ownership: an assumption is something research settled outright; a provisional decision is the pipeline's best judgment standing in for the user's until confirmed.

**At the Decisions Checkpoint**, present every provisional decision accumulated across stages 1-8 in one message:
> Reached the Decisions Checkpoint. Stages 1-8 are complete — artifacts: **[paths]**. Along the way I resolved **[N]** provisional decisions with my own best judgment: **[stage]**: **[question]**, options **[A vs B]**, I went with **[recommendation]** because **[evidence]** — repeated for each. Confirm all, or tell me which to override. This is also a good point to clear context if you'd like — resuming will pick up here.

On the answer: confirmed decisions stay as-is, and the run proceeds to stage 9 (the pre-implementation coordination check) next. An override updates the ledger and, if it invalidates downstream artifacts (e.g. an overridden spec decision the plan already built on), re-run only the affected stages before returning to this checkpoint. Do not restart from the top.

## Stage notes (where the override needs specifics)

- **Cross-workflow, three checkpoints only:** Re-run `references/cross-workflow-coordination.md` when the task is a Linear issue at exactly three points: Step 0 intake, stage 9's Pre-Implementation Gate (after the Decisions Checkpoint), and the atomic block's own final checkpoint after review. There is no per-stage re-check between stages 1-8 anymore — they no longer stop, so there is nothing to check at. Log a clear note when siblings are unrelated; only escalate on an actual file/module or requirement/scope overlap.
- **9 Pre-implementation coordination check (Linear issues only):** Runs only after the user has resumed past the Decisions Checkpoint with every provisional decision confirmed or overridden — never during stages 1-8, and never as part of that checkpoint's own output. This run compares the *finalized plan's* exact surfaces (not the spec's stated scope) against a fresh sibling scan, since siblings may have advanced since intake. See `references/cross-workflow-coordination.md`'s Pre-Implementation Gate section. Record `pre_implementation_check: passed` or `overlap_pending` in the ledger. If it finds overlap, stop with that one decision (options, recommendation, evidence) — a small checkpoint of its own, not a re-run of the Decisions Checkpoint. If clear, ledger `passed` and continue straight into `my-implement` with no separate stop. The atomic block's own final checkpoint (after review) re-runs the standard check once more, since implementation can take a while.
- **2 `my-spec` / 3 `my-clarify`:** These are the most question-prone. Most "questions" are *factual* and answerable from research + code — resolve those and record assumptions. The residue is usually a genuine scope or product-intent **decision** (what's in scope, what success means, which trade-off) — these get a recommendation and are logged as provisional rather than stopping the stage; they surface together at the single pre-implementation checkpoint. Feed clarify's resolutions back into the spec file before planning.
- **4 `my-architecture-plan`:** Its criteria come from `my-arch-review/references/protocol.md` (Structural Fit, Coupling, Cohesion, Boundary Integrity, Dependency Health), applied prospectively to the not-yet-planned change. Most questions here are factual (does this convention actually exist in the codebase? what does the current dependency graph look like?) — research them. The genuine decisions are the ones `my-arch-review`'s own Step 3 calls out: whether a proposed deviation from convention is worth its inconsistency — log the recommendation as provisional and continue rather than stopping. Its output feeds `my-plan`'s `## Architectural Constraints` section directly — pass this artifact's path into stage 5 rather than letting `my-plan` re-derive constraints independently.
- **6 `my-observe`:** It asks which observability platforms/alert channels exist. Detect from the repo first (config files, dependencies, existing dashboards/monitors, CLAUDE.md). If undetectable, default to platform-agnostic recommendations rather than asking. Its output is a companion observability plan linked to the main plan — keep it as a deliverable, not a blocker.
- **7 `my-eval-plan` (conditional):** Run it only when the plan touches an AI/LLM surface — prompts, system messages, tool docstrings, model or retrieval selection, scoring, or any behavior a model produces. Decide this from the plan's changed surfaces, not by asking. Its output is a companion eval plan linked to the main plan, the same shape as `my-observe`'s: a deliverable, not a blocker. When it does not apply, ledger it `not_applicable` with a one-line reason and move on without a checkpoint — an unset stage blocks the implementation gate, `not_applicable` does not.
- **10 `my-implement`:** The autonomous code-writing core. It orchestrates the plan one small phase at a time, dispatching each to an isolated `implementation-executor` that does red/green/validate TDD, then re-verifying the result itself. TDD is non-negotiable, and phases must be function-grained — if a plan phase is too big for a single executor, it gets split before dispatch. Honor the orchestrator's **loop detection**: if the same check fails 3× across attempts (executor + re-verify), STOP and escalate with the error output and your root-cause theory — that is a genuine blocker, not something to power through.
- **11 `my-validate`:** Run in **Plan Mode** against the plan file from stage 5. Let it self-repair trivial failures; escalate what it cannot fix confidently.
- **Compute the diff once for the review stage.** Detect the base branch and the changed files, then pass both to `my-review`:
  ```bash
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
  cur=$(git rev-parse --abbrev-ref HEAD)   # a branch is never its own base
  [ "$base" = "$cur" ] && [ "$cur" != main ] && [ "$cur" != master ] && \
    { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
  base_ref="$base"
  git show-ref --verify --quiet "refs/remotes/origin/$base" && base_ref="origin/$base"
  fork=$(git merge-base "$base_ref" HEAD)
  git diff --name-only "$fork"
  git diff "$fork"   # the review scope: every branch commit + staged + unstaged
  ```
  Diff from the merge base, not `HEAD`/`HEAD~1` and not the bare working tree — `git diff "$fork"` is the only form that covers both the branch's commits and anything still uncommitted. Pass `base_ref` and `fork` to `my-review` alongside the diff.
- **12 `my-review`:** The single, consolidated review stage. Invoke it with the base branch name so it diffs the current work tree vs `main`/`master`; stay in read-only local review — no checkout, no PR. Because this is the deliberate full pipeline, don't let lens triage thin the review:
  - **Force the full lens set active** — Security, Architecture, Performance, QA, and PM/requirements, plus whichever general lenses (Backend/Frontend/Ops/Migration/Dependency) the diff touches. The pipeline always wants the comprehensive pass, not a minimal triage.
  - **Feed the stage-2 spec as the requirements source.** Pass the spec path so `requirements-reviewer` traces acceptance criteria against the spec (and any linked Linear ticket) — this replaces the former standalone `requirements-audit` stage and satisfies its "requires a spec" need without asking.
  - It internally spawns the research subagents + the per-lens reviewers, then merges, de-dupes, runs the adversarial pass, and proposes a verdict. That single output is the pipeline's complete review surface.

## Post-Review Fix Loop

After `my-review`, inspect findings:

- **Converged**: zero Critical and zero substantive non-blocking findings -> workflow can move to final report.
- **Findings remain**: do not checkpoint. Run the next fix iteration immediately.

Each iteration:

1. `address-pr-feedback local`, passing the most recent review findings inline. Each fix lands as its own commit.
2. `my-validate` against the same plan.
3. `my-review` against the same base branch and full lens set.

Repeat until converged or 3 iterations have run. Only then stop. If Critical findings survive the 3rd pass, treat it as a genuine blocker: report the surviving findings, what each iteration changed, and a root-cause theory rather than starting a 4th pass. Update the ledger with iteration count, finding deltas, commits made, remaining findings, and exact resume command.

Each `address-pr-feedback` run appends its own `## Feedback Round N` section to the ledger — verdict table, lessons, deferrals, validation. That is the round's detail; your job here is the loop-level state above. Don't duplicate the verdict tables, and don't rewrite those sections.

If three resumed iterations do not reduce findings meaningfully, stop and surface root-cause theory instead of continuing.

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

- Run stages 1-8 back-to-back in one invocation, with a stop after stage 8 (Decisions Checkpoint); stage 9 runs only after that, stopping again only on overlap; the atomic execution/review block is the last stop.
- Research factual questions before proceeding; never ask what code, docs, tickets, or artifacts can answer.
- Resolve judgment calls with a recommendation and log them as provisional; never silently finalize a decision the user reserves.
- Keep the ledger current; it is the resume contract after context clearing, and the record of every provisional decision awaiting confirmation.
- If routing to `my-quick`, note that upfront in the workflow ledger before handoff.
- The Decisions Checkpoint should make the next command, and every open decision, obvious — and double as the intended point to clear context.
- Skipping a stage requires a current artifact and completed ledger status.
- Never start implementation from artifact inference alone; require the stage-routing implementation gate, user confirmation of provisional decisions, and a pre-implementation coordination check run *after* that confirmation.
- Surface assumptions and provisional decisions loudly, together, at the Decisions Checkpoint.
- A blocker stops the pipeline; do not work around it silently.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting. These are known failure patterns — avoid them.
