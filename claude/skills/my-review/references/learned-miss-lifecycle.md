# Learned-Miss Lifecycle

Load this for `capture` or `promote` mode and for the auto-promotion check at the
start of every review.

## `/my-review capture`

Use this source-agnostic entry when a pattern surfaces outside the normal review
prompts: a bug report, postmortem, Slack thread, or hunch.

1. Collect the Shape (a one- or two-sentence general pattern), Trigger signals,
   and source `ref`.
2. Check `learned-misses.md` and `promoted-misses.md` for a matching Shape. If
   found, append Evidence with `type: noted`, today's date, and the source `ref`.
3. Otherwise draft the entry, confirm it with the user, and write it under
   `learned-misses.md`'s `## Pending` with `status: pending`.

Do not run the review flow in this mode.

## `/my-review promote`

Use the `walk-through` skill to process each `pending` or `ready` entry:

1. Show its Shape, Trigger signals, and Evidence summary.
2. Reaffirm or revise the Shape.
3. Confirm the target: a lens reference for a positive lens check,
   `general-checklist.md` for a cross-cutting category, the relevant lens
   skill's `SKILL.md` for lens-owned behavior, or `gotchas.md` for a review-skill
   failure mode.
4. Show and confirm the exact wording.
5. On approval, write it to the target, mark it `status: promoted (<today>)`,
   and move it to `promoted-misses.md`'s `## Promoted`.
6. On rejection, mark it `status: discarded (<today>, <reason>)` and move it to
   `promoted-misses.md`'s `## Discarded`.

Do not run the review flow in this mode.

## Queue and auto-promotion

`learned-misses.md` is the active queue; `promoted-misses.md` is the archive.
Shape is the deduplication key. `caught`, `missed`, and `noted` Evidence all
count toward the threshold.

At the top of every invocation, after mode detection and before diff gathering,
auto-promote entries with at least **3** Evidence records:

1. Use `Proposed promotion: wording` when present; otherwise derive wording from
   the Shape and Evidence.
2. Use `Proposed promotion: target` when present; otherwise infer the target:
   a lens-specific positive check goes to that lens skill; a cross-cutting
   category to `general-checklist.md`; a cross-service pattern to
   `cross-service-contracts.md`; and a skill failure mode to `gotchas.md`.
3. If the target is ambiguous, mark the entry `ready` and surface it in the next
   triage for manual `/my-review promote` handling.
4. Otherwise write the promotion, mark it `promoted (<today>)`, move it to the
   archive, and report it in the next review triage.

`/my-review promote` may promote or discard an entry before it reaches the
threshold. `git revert` can undo promotion text, but the archived queue status
must also be corrected manually if later Evidence should be allowed to trigger
promotion again.
