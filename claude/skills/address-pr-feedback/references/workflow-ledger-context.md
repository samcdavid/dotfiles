# Workflow Ledger Context

Load at the very start of every run, before Step 1 (Gather All Feedback), in both PR mode and local mode. This skill can be invoked standalone on any branch, or from inside `my-workflow`'s automatic fix loop where a ledger already exists. Either way, check for it — the ledger carries the plan, spec, decisions, and requirements that produced the code under review, and working from the raw PR/diff alone risks re-litigating a decision the plan already made or missing an acceptance criterion the linked ticket alone wouldn't show.

## Step 1 — Detect

Run `git branch --show-current`, then search `~/.claude/thoughts/shared/workflows/` for a ledger whose `branch` field matches — the same branch-first convention `my-workflow` uses for its own ledger detection. No match means this branch has no tracked workflow; proceed with the rest of this skill exactly as it works standalone, no further action needed here.

## Step 2 — Read

If a matching ledger exists, read it and its recorded artifact paths — research doc, spec, architecture plan, plan, analysis report, and observability/eval companions, whichever exist. Read the plan and spec in full; skim the others for anything relevant to the feedback at hand.

## Step 3 — Fold into this skill's own steps

- **Requirements map (Step 1's Requirements Traceability Baseline).** Build the requirements map from the ledger's spec acceptance criteria and the plan's phase breakdown, in addition to any linked Linear ticket. The spec is usually more granular than the raw ticket, and the plan shows which files/changes were meant to satisfy which criterion.
- **Investigation (Step 2).** Treat a decision recorded in the ledger (spec scope call, plan architectural choice, an assumption logged during the pipeline) as settled — don't silently re-open it just because a reviewer's comment revisits it. Instead, use the recorded rationale as investigation evidence: if the comment conflicts with an explicit decision, that decision *is* your evidence for a **Disagree / Push Back** or **Valid Deferral**, per `references/pushback-patterns.md`'s Pattern 3 (evidence-backed pushback) — cite the plan/spec's stated reasoning, not just your own judgment.
- **Deferral scope.** If the ledger has a `cross_workflow` section noting sibling overlap, a reviewer's suggestion that duplicates or belongs to a sibling issue's tracked work is stronger evidence for **Valid Deferral** — cite the sibling issue and its ledger/status.
- **Fix Quality Bar / `architectural_constraints` (Act II).** Pull each relevant phase's `architectural_constraints` from the plan as a floor for this skill's own Fix Quality Bar (`references/fix-planning.md`) — a feedback fix should not violate a boundary the original plan explicitly called out. When a `my-architecture-plan` artifact exists, its own constraints are the deeper source the plan's were copied from — check a disputed structural comment against it directly if the plan's copy is ambiguous or the comment is about a boundary the plan didn't restate in full.

## What this is not

This skill never writes to the ledger — `my-workflow` owns ledger writes, and this skill stays read-only with respect to it, the same as it stays read-only with respect to the PR in PR mode. If investigating feedback surfaces something that should change the ledger (a decision the plan got wrong, an assumption that turned out false), note it in the final summary as a callout for the user to fold back into the ledger themselves — don't edit the ledger file directly.

If no ledger exists for the branch, this adds nothing and blocks nothing — the skill runs exactly as it did before this reference existed.
