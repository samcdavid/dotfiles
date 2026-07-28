# my-workflow — Gotchas

Known failure patterns for the full-pipeline orchestrator. Read before running.

## Stopping at a sub-skill's intake prompt

Every stage skill has an interactive opener ("Ready to research. What's your question?", "Describe the task…", "Do NOT proceed until confirmed"). Those are written for standalone use. Inside `my-workflow` they are **noise** — the task was established at Step 0. Supply the context from the ledger and continue. Halting here defeats the entire point of the skill.

## Asking a factual question before researching

Only stop for a *factual* question that cannot be resolved by researching the codebase, Notion, Google Drive, or Linear. A factual question that could have been answered by spawning a `codebase-analyzer`, running `notion-search`, or searching Google Drive is a protocol violation, not diligence. Run the Blocking-Question Protocol every time before you stop. (This is about *factual* questions — genuine decisions are a different thing entirely; see the next gotcha.)

## Re-discovering what an earlier stage already produced

`my-plan` should consume the stage-1 research doc and stage-2 spec by path, not re-research from scratch. `requirements-audit` should audit against the stage-2 spec, not ask for a spec source. If a later stage starts exploring ground an earlier stage already covered, you forgot to pass the artifact forward — check the ledger.

## Jumping straight to implementation

New workflows start at `my-research`, even when the user phrases the request as "build/fix/implement." Existing plans, specs, tickets, or conversation context are inputs, not permission to skip stages. `my-implement` is allowed only after the workflow ledger explicitly marks stages 1-6 complete and the user resumes after the plan/analysis checkpoints or explicitly asks to proceed with implementation.

## Silently switching to my-quick

If the work is small enough for `my-quick`, say so upfront and write it into the workflow ledger before handing off. The ledger should show `route: my-quick`, why the full pipeline was skipped, expected scope, and the exact handoff command. Do not leave a workflow ledger that looks like stage 1 started when the actual path was quick mode.

## Self-approving a decision the user owns

Decisions belong to the user — approach selection, scope trade-offs, product intent, and sign-off on the spec and the plan. Do NOT self-approve the spec or plan and march on, and do NOT auto-default a genuine decision just because a "reasonable" answer exists. That is the exact judgment the user reserves. Instead, do all the research and preparation, present the decision with options + a recommendation + the evidence, and wait. The flip side — don't over-correct into asking the user *factual* questions you could research; that's the previous gotcha. The line is: facts you resolve, decisions you tee up.

## Treating a hard failure as skippable

If `my-implement` trips loop-detection, or `my-validate` can't self-repair, or a sub-skill errors — that is a blocker. STOP and escalate with full context. Marching to the next stage on a broken foundation produces a green-looking pipeline over broken work.

## Reviewing the wrong thing in stages 9–12

The review scope is the **working-tree diff against the local base branch** (`main`/`master`), computed once and shared. Don't let `my-review` slip into PR mode (there is no PR) or review only uncommitted changes when committed-on-branch work also exists. Compute `git diff "$base"...HEAD` once and feed it to all four review stages.

## Losing the ledger on a long run

Twelve stages is a long way to fall. Persist the ledger to `~/.claude/thoughts/shared/workflows/<slug>.md` and update it as each stage finishes. If the run is interrupted and re-invoked, Step 0's detection should find the ledger and resume from the first incomplete stage — not restart at research.

## Treating one clean cross-workflow check as good for the rest of the run

Sibling ledgers advance and Linear issue statuses change between checkpoints. A "no overlap" result at intake does not carry forward — re-run `references/cross-workflow-coordination.md` before every checkpoint, not just once at Step 0. Skipping the re-check because "I already looked" is how a sibling's plan lands on the same files mid-run without anyone noticing.

## Escalating on sibling existence instead of sibling overlap

Most sibling issues on the same Linear project are unrelated. Do not stop the pipeline just because another in-progress workflow or issue shares the project — that is noise, not a decision. Only escalate to the user when there is an actual file/module overlap (surfaces named in both plans/diffs) or a requirement/scope conflict (contradictory or duplicated acceptance criteria). Everything short of that is a one-line ledger note, not a checkpoint stop.

## Forgetting where the git boundary now sits

Commits are expected: every validated implementation phase and every validated fix lands as its own local commit via the `commit` skill, so the session leaves a readable history instead of one giant working tree. The boundary is *remote* actions — no push, no PR, no thread resolution, even when the work looks finished and clean. Suggest `/create-pr` and let the user pull that trigger.
