# Protocol — my-quick

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Quick — One-Pass Implement

For changes I already understand, where running the full 8-skill pipeline would be ceremony. Implements with full TDD discipline, runs mechanical checks, and does a quick self-review — but skips spec/plan/analysis artifact generation, parallel research agents, and a separate review pass.

## When to use this skill

Use `/my-quick` when ALL of these are true:
- The change is well-understood — I can describe what to do in a sentence
- The blast radius is small and obvious
- No new module, no migration, no auth, no cross-service contract change
- Existing code in scope is familiar and well-named — no spelunking needed

Use the full pipeline (`/my-workflow`: collaborative `my-pair-plan` → fresh
pre-implementation gate → `my-implement` → `my-validate` → `implement-review`) when ANY of those
is false. The tripwire in Step 3 catches the common cases, but author judgment
is the primary gate.

## Trade-off (explicit)

This skill uses `my-implement` for one bounded edit task, then independently validates and self-reviews the result. The hand-off step explicitly recommends a follow-up `/my-review` whenever self-review surfaces real findings.

## $ARGUMENTS

A short description of the change. Examples:

- "Fix the typo on the consent page where the brand name is lowercased"
- "Add a `--dry-run` flag to the migrate task that prints SQL instead of running"
- "Extract the SVG arrow in MyComponent into a function component so it can be reused"

If empty, ask me what to change.

### Pre-confirmed feedback micro-fix

`address-pr-feedback` may invoke this workflow with a
`preconfirmed_feedback_microfix` contract after review triage. It must contain
the accepted root cause, exact behavior contract, allowed paths, and focused
proving check. Reuse that confirmation in place of the Step 1 and Step 4 user
approval pauses; it is not blanket permission to widen scope. Apply every
tripwire normally. If one fires, a check fails, or the diff exceeds the
contract, stop and return the evidence to `address-pr-feedback` for its normal
repair path. Do not ask the user to choose a lane from inside this embedded
invocation.

## Step 1 — Intake and Two-Translation

Read the request. State back:

> Here's what I understand you want and the assumptions I'm making — confirm before I proceed.

Include:
- The change (one sentence)
- The files I expect to touch
- The test approach
- Anything I'm NOT going to do

Wait for explicit confirmation or correction. Don't proceed on silence.

## Step 2 — Lightweight Context

Read the files in scope **fully**, plus their immediate callers/consumers if obvious. **No parallel research agents** — this is the deliberate cheaper path.

If a single read leaves me confused about how something works, that's a tripwire signal — escalate in Step 3.

## Step 3 — Tripwire Check

Apply `references/tripwire-signals.md`. If ANY signal fires:

**STOP.** Tell me:
- Which signal(s) fired
- Why this might not be the right lane

Ask:

> "These signals suggest this isn't actually small. Continue anyway, or escalate to the full pipeline?"

Yes → proceed. No → name the recommended starting skill (usually `/my-research` or `/my-spec`) and exit.

Do not pass tripwire without my explicit OK. Note any "continue anyway" decision in the Step 8 summary so it's visible in transcript review.

## Step 4 — Mini-Plan (Conversational)

Show me inline (NOT as a plan file):

- The change, restated as a 1-line goal
- Test(s) to write (RED phase)
- Production code to add/change (GREEN phase)
- Refactor opportunities, if obvious
- What I am NOT touching

Wait for OK before writing any code.

If the mini-plan grows beyond ~3 bullet points, that's a volume signal — escalate back to Step 3.

## Step 5 — Execute One Bounded Implementation

Create one `my-implement` slice from the approved mini-plan: desired outcome,
RED test and behavioral contract when behavior changes, GREEN change, allowed
paths, constraints, and verification commands. Invoke `my-implement`; it
performs the edit using its standard bounded-phase protocol. Do not edit the
code or test directly here.

Independently inspect the returned diff and its evidence. Do not rerun a command
that passed at the current commit; run only a missing proof or an additional
cheap broader check. If the same check fails twice after the initial attempt,
stop with the evidence and recommend the full workflow. Do not retry indefinitely.

## Step 6 — Mechanical Validation

Run, in order, only when the implementation evidence does not already cover it:

1. The full test file for the changed area
2. Linter / formatter scoped to changed files
3. Type checker if the language has one

Self-repair is allowed for trivial failures (formatting, lint nits). For type errors or test failures that aren't trivially fixable, surface them — don't blunt-force.

## Step 7 — Self-Review

Walk the diff against `references/self-review-checklist.md`. Output as text grouped by severity.

**Do NOT auto-edit** based on self-review findings. Surface them. Let me decide what to fix.

End the self-review with the explicit note:

> "This is a self-review by the same Claude that implemented the change. It's a sanity check, not a substitute for `/my-review`."

## Step 8 — Stop and Hand Off

Print:

- Files changed (paths + line counts)
- Tests run + result
- Self-review findings, if any
- Any tripwire "continue anyway" decisions from Step 3
- Suggested next steps:
  - `/create-pr` if ready for review
  - `/my-review` if any self-review finding looks substantial

The validated phase is already committed by `my-implement`. **Do NOT push or create PRs.** The hand-off IS the stopping point.

## Guidelines

- The tripwire is the safety net. Trust it. False alarms are cheap; false negatives are expensive.
- Self-review is a sanity check, not a quality gate. Recommend `/my-review` for non-trivial findings.
- Don't generate spec/plan/analysis files. If you find yourself wanting to, that's a tripwire signal — escalate.
- TDD discipline is non-negotiable. The fast lane skips planning ceremony, NOT correctness ceremony; behavioral edits still enter `my-implement` with an honest RED test.
- One-pass means one pass. Don't re-implement after self-review unless I direct it.
- Do not create a second commit. The hand-off is the stopping point.

## References

- `references/tripwire-signals.md` — escalation criteria
- `references/self-review-checklist.md` — the quick review pass

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
