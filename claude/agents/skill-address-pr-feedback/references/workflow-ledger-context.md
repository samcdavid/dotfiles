# Workflow Ledger Context — skill-address-pr-feedback

Load at the very start of every run, before Step 1 (Gather All Feedback), in both PR mode and local mode. This skill can be invoked standalone on any branch, or from inside `my-workflow`'s automatic fix loop where a ledger already exists. Either way, check for it — the ledger carries the plan, spec, decisions, and requirements that produced the code under review, and working from the raw PR/diff alone risks re-litigating a decision the plan already made or missing an acceptance criterion the linked ticket alone wouldn't show.

The ledger is both an input and an output here: steps 1-3 read it, and step 4 appends this run's round record to it. A feedback round is the densest source of what the plan got wrong, and a round that only exists in a finished session's transcript is lost.

## Step 1 — Detect

Run `git branch --show-current`, then search `~/.claude/thoughts/shared/workflows/` for a ledger whose `branch` field matches — the same branch-first convention `my-workflow` uses for its own ledger detection. No match means this branch has no tracked workflow; proceed with the rest of this skill exactly as it works standalone, no further action needed here.

## Step 2 — Read

If a matching ledger exists, read it and its recorded artifact paths — research doc, spec, architecture plan, plan, analysis report, and observability/eval companions, whichever exist. Read the plan and spec in full; skim the others for anything relevant to the feedback at hand.

## Step 3 — Fold into this skill's own steps

- **Requirements map (Step 1's Requirements Traceability Baseline).** Build the requirements map from the ledger's spec acceptance criteria and the plan's phase breakdown, in addition to any linked Linear ticket. The spec is usually more granular than the raw ticket, and the plan shows which files/changes were meant to satisfy which criterion.
- **Investigation (Step 2).** Treat a decision recorded in the ledger (spec scope call, plan architectural choice, an assumption logged during the pipeline) as settled — don't silently re-open it just because a reviewer's comment revisits it. Instead, use the recorded rationale as investigation evidence: if the comment conflicts with an explicit decision, that decision *is* your evidence for a **Disagree / Push Back** or **Valid Deferral**, per `references/pushback-patterns.md`'s Pattern 3 (evidence-backed pushback) — cite the plan/spec's stated reasoning, not just your own judgment.
- **Deferral scope.** If the ledger has a `cross_workflow` section noting sibling overlap, a reviewer's suggestion that duplicates or belongs to a sibling issue's tracked work is stronger evidence for **Valid Deferral** — cite the sibling issue and its ledger/status.
- **Fix Quality Bar / `architectural_constraints` (Act II).** Pull each relevant phase's `architectural_constraints` from the plan as a floor for this skill's own Fix Quality Bar (`references/fix-planning.md`) — a feedback fix should not violate a boundary the original plan explicitly called out. When a `my-architecture-plan` artifact exists, its own constraints are the deeper source the plan's were copied from — check a disputed structural comment against it directly if the plan's copy is ambiguous or the comment is about a boundary the plan didn't restate in full.

## Step 4 — Append the round record

Runs last, after the Step 11 summary in local mode and after Step 12 publishing in PR mode, so the record can state what actually landed. Append one dated section per run:

```markdown
## Feedback Round N — [source] ([mode], YYYY-MM-DD)

[One or two sentences: where the feedback came from — reviewer/bot login and PR
number in PR mode, "self-run my-review, fix-loop iteration K" in local mode —
and anything that reframes earlier ledger entries, e.g. a PR now existing.]

| # | Finding | Verdict | Commit |
|---|---|---|---|
| 1 | [short description] | Fixed / Partially correct / Push back / Deferred / Already addressed | `[sha]` or — |

### Things worth remembering from this round

- [Lesson, correction, or falsified assumption — with the evidence that settled it.]

### Deliberately deferred, with reasons

- [Item] — [why, and the concrete follow-up plan or ticket.]

**Validation:** [test/lint/build results.] [PR mode: what was pushed, replied to,
resolved, re-requested.]
```

Number the round by counting existing `## Feedback Round` sections plus any hand-written review-round sections already in the file; continue that sequence rather than restarting at 1.

What belongs in "Things worth remembering" is the material that would change how the next round runs: an adversarial verdict that reversed your own argument, a reviewer citation that turned out fabricated, a recurring defect pattern the ledger has now seen more than once, a plan decision the feedback proved wrong. Not a restatement of the verdict table.

## Write boundaries

- **Append only.** Never edit or rewrite an existing section — not stage statuses, artifacts, provisional decisions, `cross_workflow`, nor a prior round's record. `my-workflow` owns those, and it may be mid-run.
- **Corrections are new text, not edits.** If this round proves an earlier ledger claim wrong, say so in the new section and point back at the section it corrects. Leaving the original wrong claim visible next to its correction is the point — that history is why the ledger is worth keeping.
- **Update the frontmatter `updated:` date, and `pr:` if this run is the first to have a PR.** Those two fields are safe; leave every other frontmatter key alone.
- **A ledger write is not an outward action.** It is a local file under `~/.claude/thoughts/`, so `no-outward-actions.md` does not gate it. It is also not a substitute for the Step 11 summary — write both.
- **Never create a ledger.** If no ledger matches the branch, there is nothing to append to; skip this step silently. Do not open one on this skill's behalf — ledger creation is `my-workflow`'s Step 0.

If no ledger exists for the branch, this whole reference adds nothing and blocks nothing — the skill runs exactly as it did before it existed.
