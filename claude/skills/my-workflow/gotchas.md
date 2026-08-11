# my-workflow — Gotchas

Known failure patterns for the full-pipeline orchestrator. Read before running.

## Stopping at a sub-skill's intake prompt

Every stage skill has an interactive opener ("Ready to research. What's your question?", "Describe the task…", "Do NOT proceed until confirmed"). Those are written for standalone use. Inside `my-workflow` they are **noise** — the task was established at Step 0. Supply the context from the ledger and continue. Halting here defeats the entire point of the skill.

## Asking a factual question before researching

Only stop for a *factual* question that cannot be resolved by researching the codebase, Notion, Google Drive, or Linear. A factual question that could have been answered by spawning a `codebase-analyzer`, running `notion-search`, or searching Google Drive is a protocol violation, not diligence. Run the Blocking-Question Protocol every time before you stop. (This is about *factual* questions — genuine decisions are a different thing entirely; see the next gotcha.)

## Starting a second ledger for a branch that already has one

Always run `git branch --show-current` and check for a ledger whose `branch` field matches before parsing `$ARGUMENTS` into what looks like a fresh task. If you're on a feature branch with an existing ledger, that ledger is the one — resume it and use its recorded task with no confirmation step, even if this invocation's phrasing reads like a new or different request. There is exactly one ledger per branch. Do not open a second one because the phrasing doesn't match; the only way a branch gets a new ledger while an old one exists is the user explicitly saying to abandon or replace it. Only fall back to matching by Linear ID, ticket slug, or topic when on the default branch (`main`/`master`, where several ledgers can legitimately coexist) or when no ledger's `branch` field matches at all. If the branch was renamed and the ledger's `branch` field is now stale, a Linear ID/topic cross-check will still find it — update the field once confirmed rather than leaving it pointing at a branch that no longer exists.

## Re-discovering what an earlier stage already produced

`my-plan` should consume the stage-1 research doc and stage-2 spec by path, not re-research from scratch. `requirements-audit` should audit against the stage-2 spec, not ask for a spec source. If a later stage starts exploring ground an earlier stage already covered, you forgot to pass the artifact forward — check the ledger.

## Jumping straight to implementation

New workflows start at `my-research`, even when the user phrases the request as "build/fix/implement." Existing plans, specs, tickets, or conversation context are inputs, not permission to skip stages. `my-implement` is allowed only after the workflow ledger explicitly marks stages 1-8 complete, every entry under `## Provisional Decisions` is confirmed or overridden at the Decisions Checkpoint, `cross_workflow.pre_implementation_check` is `passed` for the current plan version (not `not_run`, unset, or `overlap_pending`), and that check was run *after* the Decisions Checkpoint — not before it, and not reused from an earlier stage. A clean cross-workflow result from an earlier stage does not carry forward to the gate on its own — the pre-implementation coordination check (stage 9) re-runs fresh regardless, because the plan may have changed since and siblings may have advanced.

## Running the pre-implementation coordination check before the Decisions Checkpoint

Stage 9 exists to catch sibling drift right before code changes land — that guarantee only holds if it runs *after* the user has reviewed and confirmed everything from stages 1-8. Running it earlier (during stages 1-8, or bundling it into the Decisions Checkpoint's own output "since the data's already there") defeats the point twice over: it checks against a plan the user hasn't signed off on yet, and it removes the natural pause where the user can clear context before the next stretch of work. The Decisions Checkpoint must fire and get a resume first; stage 9 is the very next thing after that, never before.

## Silently switching to my-quick

If the work is small enough for `my-quick`, say so upfront and write it into the workflow ledger before handing off. The ledger should show `route: my-quick`, why the full pipeline was skipped, expected scope, and the exact handoff command. Do not leave a workflow ledger that looks like stage 1 started when the actual path was quick mode.

## Invoking my-quick right after ledgering the route, without waiting for approval

Ledgering the `route: my-quick` decision is necessary but not sufficient. The route choice is itself a user-owned decision (same class as "Self-approving a decision the user owns" below) — skipping research/spec/clarify/architecture-plan/plan/observe/analyze on the user's behalf, even for a well-evidenced ticket, is a call the user gets to make, not one to log-and-proceed on. After writing the route decision to the ledger, stop and present it (route + one-sentence reason + expected scope + exact handoff command) and wait for explicit confirmation before calling `Skill(my-quick)`. Concretely: end the turn there; do not chain the routing message and the `my-quick` invocation together in the same turn. Caught when the user was surprised by a batch of file edits landing in their working tree with no chance to redirect first, even though the ledger note itself was correct and complete.

## Self-approving a decision the user owns

Decisions belong to the user — approach selection, scope trade-offs, product intent, and sign-off on the spec and the plan. Do the research, form a recommendation, and pick it so the pipeline can keep moving — but do NOT drop it silently into a plain assumption. Log it under the ledger's `## Provisional Decisions` section with the options, the recommendation, and the evidence, and it must reach the user at the Decisions Checkpoint for confirmation or override. "I resolved it and kept going" is fine; "I resolved it and it never surfaced again" is self-approval. The flip side — don't over-correct into asking the user *factual* questions you could research; that's the previous gotcha. The line is: facts you resolve and log as assumptions (done, no confirmation needed), decisions you resolve and log as provisional (done for now, but still awaiting the user's sign-off).

## Treating a hard failure as skippable

If `my-implement` trips loop-detection, or `my-validate` can't self-repair, or a sub-skill errors — that is a blocker. STOP and escalate with full context. Marching to the next stage on a broken foundation produces a green-looking pipeline over broken work.

## Reviewing the wrong thing in stages 10–13

The review scope is the **whole branch against the base branch** (`main`/`master`), computed once and shared. Don't let `my-review` slip into PR mode (there is no PR), review only uncommitted changes when committed-on-branch work also exists, or review only the last commit when the branch has several. Compute `fork=$(git merge-base "$base_ref" HEAD); git diff "$fork"` once — that range covers every branch commit plus staged and unstaged work — and feed it to all four review stages.

## Losing the ledger on a long run

Eight stages now run back-to-back with zero stops before the Decisions Checkpoint — that's a long unattended stretch to lose if something interrupts it. Persist the ledger to `~/.claude/thoughts/shared/workflows/<slug>.md` and update it silently as each stage finishes, including every provisional decision the moment it's made. If the run is interrupted and re-invoked, Step 0's detection should find the ledger and resume from the first incomplete stage — not restart at research, and not re-litigate a provisional decision that was already logged.

## Treating one clean cross-workflow check as good for the rest of the run

Sibling ledgers advance and Linear issue statuses change between checkpoints. A "no overlap" result at intake does not carry forward to the pre-implementation gate — re-run `references/cross-workflow-coordination.md` fresh at each of the three points it applies (Step 0 intake, stage 9's Pre-Implementation Gate after the Decisions Checkpoint, the atomic block's final checkpoint), not just once. Skipping the re-check because "I already looked" is how a sibling's plan lands on the same files mid-run without anyone noticing. (Stages 1-8 no longer stop at all, so there's nothing to re-check between them — the three points above are the whole list now.)

## Escalating on sibling existence instead of sibling overlap

Most sibling issues on the same Linear project are unrelated. Do not stop the pipeline just because another in-progress workflow or issue shares the project — that is noise, not a decision. Only escalate to the user when there is an actual file/module overlap (surfaces named in both plans/diffs) or a requirement/scope conflict (contradictory or duplicated acceptance criteria). Everything short of that is a one-line ledger note, not a checkpoint stop.

## Forgetting where the git boundary now sits

Commits are expected: every validated implementation phase and every validated fix lands as its own local commit via the `commit` skill, so the session leaves a readable history instead of one giant working tree. The boundary is *remote* actions — no push, no PR, no thread resolution, even when the work looks finished and clean. Suggest `/create-pr` and let the user pull that trigger.

## Treating "no separate stop" at stage 9 as authorization to dispatch my-implement

The protocol says a clean pre-implementation-check (stage 9, no sibling overlap) flows straight into the atomic block with no separate stop — that line describes when the *pipeline* is allowed to proceed, not when *this user* has actually authorized code to be written. Caught on MCP-523: Decisions Checkpoint was confirmed, stage 9 passed clean, phase tasks were staged, and the first `implementation-executor` dispatch was about to fire — the user interrupted: "You didn't have approval to implement yet, just approval of decisions." Confirming the Decisions Checkpoint approves the *decisions*; it is a separate question whether the user is also greenlighting `my-implement` right now. Stop and ask explicitly before dispatching the first executor, even on a clean stage 9 pass — do not treat "the protocol allows continuing" as "the user told me to continue." Same shape as the `my-quick` approval gotcha above, at a different transition point in the same pipeline.
