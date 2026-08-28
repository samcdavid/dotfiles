# Workflow Ledger Context — skill-address-pr-feedback

Load at the very start of every run, before Step 1 (Gather All Feedback), in both PR mode and local mode. This skill can be invoked standalone on any branch, or with a `my-workflow` ledger already present. Either way, check for it — the living ledger carries the need, requirements, decisions, architecture, test strategy, and implementation plan that produced the code under review, and working from the raw PR/diff alone risks re-litigating a decision or missing an acceptance criterion.

The ledger is both an input and an output here: steps 1-3 read it, and step 4 appends this run's round record and final finding dispositions to it. A feedback round is the densest source of what the plan got wrong, and a round that only exists in a finished session's transcript is lost.

## Step 1 — Detect

Run `git branch --show-current`, then search `~/.claude/thoughts/shared/workflows/` for a ledger whose `branch` field matches — the same branch-first convention `my-workflow` uses for its own ledger detection. No match means this branch has no tracked workflow; proceed with the rest of this skill exactly as it works standalone, no further action needed here.

## Step 2 — Read

If a matching ledger exists, read it completely. The current format is the
canonical planning document; legacy ledgers may instead link separate research,
spec, architecture, test, plan, analysis, and observability/eval artifacts, which
should be read as before. Also read `## Finding Register` using
`my-review/references/finding-ledger.md`, retaining the latest row for each key.

## Step 3 — Fold into this skill's own steps

- **Requirements map (Step 1's Requirements Traceability Baseline).** Build the requirements map from the ledger's Need Summary, Requirements, Test Strategy, Traceability, and Implementation Plan, plus the linked Linear ticket.
- **Investigation (Step 2).** Treat a confirmed ledger decision as settled — don't silently re-open it just because a reviewer's comment revisits it. Use its recorded rationale as evidence for **Disagree / Push Back** or **Valid Deferral** when appropriate.
- **Deferral scope.** If the ledger has a `cross_workflow` section noting sibling overlap, a reviewer's suggestion that duplicates or belongs to a sibling issue's tracked work is stronger evidence for **Valid Deferral** — cite the sibling issue and its ledger/status.
- **Fix Quality Bar / architectural constraints (Act II).** Pull the relevant phase and Architecture-section constraints from the ledger as a floor for this skill's Fix Quality Bar. For legacy ledgers, retain the separate architecture-plan lookup.
- **Finding dedupe (Act I).** Match feedback to the latest Finding Register key before investigation. An unchanged `resolved` or `deferred` concern is already settled: do not re-plan it or spend another repair pass. Reopen only with the concrete trigger required by `finding-ledger.md`; otherwise report the prior disposition compactly if the reviewer needs a response.
- **Accepted review handoffs are not defect dispositions.** An `accepted` row
  for `review-handoff.local-sensitive-changes` suppresses only repeated advisory
  acknowledgement; `review-handoff.operational-readiness` suppresses only the
  exact environment-variable, feature-flag, and migration readiness facts it
  records. Neither can dismiss, defer, or avoid investigating actual review
  feedback, and the advisory key never satisfies the operational key.

## Step 4 — Append the round record and finding dispositions

Runs last, after the Step 11 summary in local mode and after Step 12 publishing in PR mode, so the record can state what actually landed. Append one dated section per run:

```markdown
## Feedback Round N — [source] ([mode], YYYY-MM-DD)

[One or two sentences: where the feedback came from — reviewer/bot login and PR
number in PR mode, "self-run my-review, fix-loop iteration K" in local mode —
and anything that reframes earlier ledger entries, e.g. a PR now existing.]

| # | Key | Finding | Verdict | Commit |
|---|---|---|---|---|
| 1 | `subsystem.concern` | [short description] | Fixed / Partially correct / Push back / Deferred / Already addressed | `[sha]` or — |

### Things worth remembering from this round

- [Lesson, correction, or falsified assumption — with the evidence that settled it.]

### Deliberately deferred, with reasons

- [Item] — [why, and the concrete follow-up plan or ticket.]

**Validation:** [test/lint/build results.] [PR mode: what was pushed, replied to,
resolved, re-requested.]
```

After the round record, create `## Finding Register` if it does not yet exist,
then append one row for every finding that has an honest final disposition using
the exact schema in `my-review/references/finding-ledger.md`. `Fixed`, verified
`Already addressed`, and evidence-backed `Push back` become `resolved` with
their proof. A `Valid Deferral` becomes `deferred` only with its verified,
specific follow-up/clearing condition. Reuse the review-supplied key, or derive
one with that reference when feedback originated outside `my-review`.

Do not add a row for `Scope Decision Required`, a failed/incomplete repair, or a
finding left open by the review-pass cap. Surface those as unsettled instead of
lying with a resolved/deferred label. When a key was reopened, append the new
row with the same key and name the changed-code or new-evidence trigger.

Number the round by counting existing `## Feedback Round` sections plus any hand-written review-round sections already in the file; continue that sequence rather than restarting at 1.

What belongs in "Things worth remembering" is the material that would change how the next round runs: an adversarial verdict that reversed your own argument, a reviewer citation that turned out fabricated, a recurring defect pattern the ledger has now seen more than once, a plan decision the feedback proved wrong. Not a restatement of the verdict table.

## Write boundaries

- **Append only.** Never edit or rewrite planning sections, decisions, execution
  history, cross-workflow state, or a prior round. `my-workflow` owns them and
  may be mid-run.
- **Corrections are new text, not edits.** If this round proves an earlier ledger claim wrong, say so in the new section and point back at the section it corrects. Leaving the original wrong claim visible next to its correction is the point — that history is why the ledger is worth keeping.
- **Update the frontmatter `updated:` date, and `pr:` if this run is the first to have a PR.** Those two fields are safe; leave every other frontmatter key alone.
- **A ledger write is not an outward action.** It is a local file under `~/.claude/thoughts/`, so `no-outward-actions.md` does not gate it. It is also not a substitute for the Step 11 summary — write both.
- **Never create a ledger.** If no ledger matches the branch, there is nothing to append to; skip this step silently. Do not open one on this skill's behalf — ledger creation is `my-workflow`'s Step 0.

If no ledger exists for the branch, this whole reference adds nothing and blocks nothing — the skill runs exactly as it did before it existed.
