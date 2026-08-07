# Protocol — my-workflow

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## My Workflow

Orchestrate the delivery pipeline as resumable stage work. The task is established once at intake, artifacts carry context between stages, and the workflow ledger is the resume source of truth.

Each major stage stops for user review after producing its artifact. The user can clear context and invoke `my-workflow` again; the next run reads the ledger and continues from the earliest incomplete stage.

The exception is the atomic execution/review block: once gated implementation starts, run `my-implement`, then the automatic fix loop (`my-validate` -> `my-review` -> `address-pr-feedback local`, repeating until clean or 3 iterations), without stopping between them. Stop after the final review output. Implementation cannot start from a new workflow or loose artifacts; it requires completed ledger status for all prior stages.

Factual questions are still handled autonomously through research. Genuine decisions remain user-owned.

## What this is — and is not

- This skill **runs the real skills in order via the Skill tool**. It does NOT reimplement them. Each stage's skill remains the single source of truth for that stage.
- Contrast with `/my-quick`: that collapses a *subset* of this flow into one fast inline pass for small, well-understood changes. `my-workflow` is the deliberate opposite for substantial work. If intake routes to `my-quick`, record that route and reason in the workflow ledger before handing off.
- It commits locally as work lands — each validated phase and fix gets its own commit via the `commit` skill — but performs **no remote git actions**. It never pushes or opens a PR. The hand-off summary is the stopping point.

## Governing Constraints

These override sub-skill instructions.

1. **One intake, staged checkpoints.** Capture task/context once in Step 0. After go-ahead, run the current stage autonomously, update the ledger, then stop for user review. Do not chain to the next stage except inside the atomic execution/review block.
2. **Resume from artifacts.** On a later run, read the ledger and continue from the earliest incomplete stage. Do not redo completed stage work unless its input artifact changed.
3. **Research before asking factual questions.** Answer knowable questions from code, Notion, Google Drive, Linear, and artifacts; log factual assumptions in the ledger.
4. **Decisions belong to the user.** Approach selection, scope trade-offs, product intent, and spec/plan approval are user decisions. Prepare evidence and recommendation, then stop.
5. **Atomic execution/review block.** Implementation is gated. Start it only when the ledger explicitly marks stages 1-7 complete, the pre-implementation coordination check `passed` for the current plan version (or has no unresolved overlap), and the user resumed after reviewing the plan/analysis checkpoints or explicitly requested implementation. Once implementation starts, run `my-implement`, then the automatic fix loop, without stopping between them. Stop after the final review output.
6. **Fix loop runs unattended.** After `my-implement`, loop `my-validate` -> `my-review` -> `address-pr-feedback local` until a review pass is clean of Critical and substantive non-blocking findings, capped at 3 iterations. No checkpoint between iterations; stop once after the final review. Nits never trigger another iteration.
7. **No remote actions.** Local commits per validated phase/fix are expected. No `git push`, `gh pr create`, published replies, or state-changing remote calls unless explicitly requested.
8. **Carry artifacts forward.** Each stage's output is the next stage's input. Track concrete paths/IDs in the ledger.
9. **Cross-workflow coordination runs every checkpoint.** When the task is a Linear issue, re-run `references/cross-workflow-coordination.md` before each checkpoint output — sibling ledgers and sibling issues can change between checkpoints. Log a note when siblings are clear; escalate to the user only on an actual file/module or requirement/scope overlap, per that reference's escalation bar.

## Pipeline Exact Order

| # | Stage | Consumes | Produces | Checkpoint |
|---|---|---|---|---|
| 1 | `my-research` | task / ticket | research doc | stop |
| 2 | `my-spec` | research + task | spec | stop |
| 3 | `my-clarify` | spec | clarified spec | stop |
| 4 | `my-architecture-plan` | clarified spec + research | architecture plan | stop |
| 5 | `my-plan` | spec + research + architecture plan | plan | stop |
| 6 | `my-observe` | plan | observability companion | stop |
| 7 | `my-eval-plan` (conditional) | plan | eval companion | stop |
| 8 | `my-analyze` | research + spec + plan + companions | consistency report | stop |
| 9 | Pre-implementation coordination check (Linear issues only) | finalized plan + fresh sibling ledger/issue scan | updated `cross_workflow` ledger section, resolved overlaps | stop only if overlap found |
| 10-12 | gated atomic block: `my-implement` -> automatic fix loop | approved plan + completed stage 1-9 ledger | commits per phase, validation report, review verdict | stop after final review |
| loop | `my-validate` -> `my-review` -> `address-pr-feedback local`, max 3 iterations | review findings | fix commits, validation, new review verdict | no stop between iterations |

Track stages in the ledger. Mark each `in_progress` when it starts and `completed` when output exists. A checkpoint is an intentional stop, not a blocker.

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

Mode: I run one stage at a time, checkpoint after each artifact, and give you an exact resume command. You can clear context between stages. The only uninterrupted block is `my-implement` plus the automatic fix loop (`my-validate` -> `my-review` -> `address-pr-feedback local`, up to 3 passes), and it is available only after the ledger marks research, spec, clarify, architecture plan, plan, observe, and analyze complete, with eval-plan either complete or not applicable. Factual questions are researched; decisions stay yours. Each validated phase and fix is committed locally so the session leaves a readable history; no pushes, PRs, or other outward actions unless explicitly requested. When the task shares a Linear project or milestone with other in-progress work, I re-check for sibling overlap at every checkpoint and only stop you for an actual file/module or requirement conflict, not just because a sibling exists.

Starting assumptions: **[list]**.
```

Wait for go-ahead once to start the selected stage.

6. **Open ledger.** Create/update `~/.claude/thoughts/shared/workflows/<slug>.md` with task, `branch` (the current git branch — the primary lookup key for future invocations per Step 1), `base_branch` (the diff target for review, usually `main`/`master`), chosen entry point, route, stage statuses, artifact paths, decisions, autonomous assumptions, and (when applicable) the `cross_workflow` section from `references/cross-workflow-coordination.md`. New full-pipeline ledgers start with all stages incomplete. Quick-handoff ledgers record the route and handoff command instead of stage completion. Update it at every checkpoint; if the branch changes mid-workflow (renamed, or moved intentionally), update `branch` too rather than leaving it stale.

## Autonomy Override

For the selected stage, invoke the stage skill with established context: task plus concrete artifact paths/IDs from the ledger. Then follow that skill with these adjustments:

- **Intake prompts stay internal.** If the stage skill asks for topic/context, provide it from the ledger and continue within the stage.
- **Factual gates are researched.** If the stage asks to confirm how code behaves, what requirements say, or whether wiring exists, verify through code/docs/tickets/artifacts and log the factual assumption.
- **Decision gates stop.** If the stage reaches approach choice, scope trade-off, product intent, or spec/plan approval, prepare options and recommendation, then stop for the user.
- **Question batches are filtered.** For `my-spec`, `my-clarify`, `my-architecture-plan`, and `my-plan`, answer factual questions through the Blocking-Question Protocol and surface only real decisions.
- **Plan approval is user-owned.** The plan may be written before approval, but implementation cannot start until the user resumes after approving it and the ledger marks stages 1-7 complete.
- **Stage boundary is hard.** When the selected stage completes, checkpoint and stop unless currently inside the atomic block (`my-implement` plus the fix loop).
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
   - **A genuine decision** → it does NOT get auto-defaulted. Prepare it for the user: the options, the pros/cons, your recommendation, and the evidence you gathered. Carry it to the batched stop.

A question reaches the user only if it is a **genuine decision** that steps 1–3 could not convert into a fact. Decisions are never resolved by "a competent engineer could pick something" — that is exactly the judgment the user reserves.

**When you stop**, batch all surviving decisions into one message:
> Reached a decision point at **[stage]**. I researched **[code / Notion / Google Drive / Linear / artifacts]** and resolved the factual questions (**[X, Y]**, logged as assumptions). I need your decision on: **[the decisions]** — options: **[A vs B]**, my recommendation: **[…]** because **[evidence]**.

On the answer, resume from that stage with the decision folded into the ledger. Do not restart from the top.

## Stage notes (where the override needs specifics)

- **Every stage, cross-workflow:** Before writing the checkpoint output, re-run `references/cross-workflow-coordination.md` when the task is a Linear issue. Sibling ledgers and Linear issue status can change between checkpoints — do not rely on the intake-time result past stage 1. Log a clear note when siblings are unrelated; only escalate on an actual file/module or requirement/scope overlap.
- **9 Pre-implementation coordination check (Linear issues only):** A mandatory gate, not a repeat of the standing per-checkpoint note above — this run compares the *finalized plan's* exact surfaces (not the spec's stated scope) against a fresh sibling scan, since siblings may have advanced since the last checkpoint. See `references/cross-workflow-coordination.md`'s Pre-Implementation Gate section. Record `pre_implementation_check: passed` or `overlap_pending` in the ledger. Stop only if it surfaces overlap; when clear, continue straight into `my-implement` with no separate checkpoint. The atomic block's own final checkpoint (after review) re-runs the standard check once more, since implementation can take a while.
- **2 `my-spec` / 3 `my-clarify`:** These are the most question-prone. Most "questions" are *factual* and answerable from research + code — resolve those and record assumptions. The residue is usually a genuine scope or product-intent **decision** (what's in scope, what success means, which trade-off) — surface those to the user rather than deciding for them. Feed clarify's resolutions back into the spec file before planning.
- **4 `my-architecture-plan`:** Its criteria come from `my-arch-review/references/protocol.md` (Structural Fit, Coupling, Cohesion, Boundary Integrity, Dependency Health), applied prospectively to the not-yet-planned change. Most questions here are factual (does this convention actually exist in the codebase? what does the current dependency graph look like?) — research them. The genuine decisions are the ones `my-arch-review`'s own Step 3 calls out: whether a proposed deviation from convention is worth its inconsistency. Its output feeds `my-plan`'s `## Architectural Constraints` section directly — pass this artifact's path into stage 5 rather than letting `my-plan` re-derive constraints independently.
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

- Run one checkpointed stage per invocation, except for the atomic execution/review block.
- Research factual questions before asking; never ask what code, docs, tickets, or artifacts can answer.
- Do not decide judgment calls the user reserves.
- Keep the ledger current; it is the resume contract after context clearing.
- If routing to `my-quick`, note that upfront in the workflow ledger before handoff.
- Every checkpoint should make the next command obvious.
- Skipping a stage requires a current artifact and completed ledger status.
- Never start implementation from artifact inference alone; require the stage-routing implementation gate.
- Surface assumptions loudly.
- A blocker stops the pipeline; do not work around it silently.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting. These are known failure patterns — avoid them.
