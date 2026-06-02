# my-workflow — Gotchas

Known failure patterns for the full-pipeline orchestrator. Read before running.

## Stopping at a sub-skill's intake prompt

Every stage skill has an interactive opener ("Ready to research. What's your question?", "Describe the task…", "Do NOT proceed until confirmed"). Those are written for standalone use. Inside `my-workflow` they are **noise** — the task was established at Step 0. Supply the context from the ledger and continue. Halting here defeats the entire point of the skill.

## Asking before researching

The user's hard requirement: only stop for input that cannot be resolved by researching the codebase, Notion, or Google Drive. A question that could have been answered by spawning a `codebase-analyzer`, running `notion-search`, or searching Google Drive is a protocol violation, not diligence. Run the four-step Blocking-Question Protocol every time before you even consider stopping.

## Re-discovering what an earlier stage already produced

`my-plan` should consume the stage-1 research doc and stage-2 spec by path, not re-research from scratch. `requirements-audit` should audit against the stage-2 spec, not ask for a spec source. If a later stage starts exploring ground an earlier stage already covered, you forgot to pass the artifact forward — check the ledger.

## Self-approval drift into approval gates

The chosen mode is fully autonomous: no spec gate, no plan gate. It's tempting to "just confirm the plan looks right" with the user — don't. Self-approve, log it, proceed. The user reviews everything at the end. (If the user later wants gates, that's a different mode, not a quiet behavior change.)

## Treating a hard failure as skippable

If `my-implement` trips loop-detection, or `my-validate` can't self-repair, or a sub-skill errors — that is a blocker. STOP and escalate with full context. Marching to the next stage on a broken foundation produces a green-looking pipeline over broken work.

## Reviewing the wrong thing in stages 9–12

The review scope is the **working-tree diff against the local base branch** (`main`/`master`), computed once and shared. Don't let `my-review` slip into PR mode (there is no PR) or review only uncommitted changes when committed-on-branch work also exists. Compute `git diff "$base"...HEAD` once and feed it to all four review stages.

## Losing the ledger on a long run

Twelve stages is a long way to fall. Persist the ledger to `~/.claude/thoughts/shared/workflows/<slug>.md` and update it as each stage finishes. If the run is interrupted and re-invoked, Step 0's detection should find the ledger and resume from the first incomplete stage — not restart at research.

## Forgetting the no-git boundary

The hand-off is the stopping point. No commit, no push, no PR — even if the work looks finished and clean. Suggest `/commit` and `/create-pr`; let the user pull the trigger.
