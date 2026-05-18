---
name: my-quick
description: One-pass implement for small, well-known changes. Collapses the my-research → my-spec → my-clarify → my-plan → my-analyze → my-implement → my-validate → my-review flow into a single lightweight pass with full TDD discipline. Trips out and asks before continuing when signals suggest the change isn't actually small. Stops after self-review — does not commit or push.
disable-model-invocation: true
---

# Quick — One-Pass Implement

For changes I already understand, where running the full 8-skill pipeline would be ceremony. Implements with full TDD discipline, runs mechanical checks, and does a quick self-review — but skips spec/plan/analysis artifact generation, parallel research agents, and a separate review pass.

## When to use this skill

Use `/my-quick` when ALL of these are true:
- The change is well-understood — I can describe what to do in a sentence
- The blast radius is small and obvious
- No new module, no migration, no auth, no cross-service contract change
- Existing code in scope is familiar and well-named — no spelunking needed

Use the heavy pipeline (`/my-research → /my-spec → /my-clarify → /my-plan → /my-analyze → /my-implement → /my-validate → /my-review`) when ANY of those is false. The tripwire in Step 3 catches the common cases, but author judgment is the primary gate.

## Trade-off (explicit)

This skill violates the global **Separate Implementer from Reviewer** principle from `~/.claude/CLAUDE.md` — the same Claude implements AND self-reviews. The fast lane accepts this trade for speed on small work. The skill's hand-off step explicitly recommends a follow-up `/my-review` whenever self-review surfaces real findings.

## $ARGUMENTS

A short description of the change. Examples:

- "Fix the typo on the consent page where 'dscout' should be 'Dscout'"
- "Add a `--dry-run` flag to the migrate task that prints SQL instead of running"
- "Extract the SVG arrow in MyComponent into a function component so it can be reused"

If empty, ask me what to change.

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

## Step 5 — TDD Implement

Strict red/green/refactor, mirrored from `/my-implement`.

### RED — failing test first

1. Write the test
2. Run it — must FAIL for the right reason (missing behavior, not a syntax error)
3. If it passes immediately, the test is wrong — rewrite

**Hard rule:** do not proceed to GREEN until the test fails for the right reason.

### GREEN — minimum code to pass

1. Write the smallest production code change that satisfies the test
2. Run the test — must PASS
3. Run the broader test file/module — nothing unrelated should break

### REFACTOR (optional)

Only if there's something genuinely better to do. Don't gold-plate. Tests must still pass after.

### Loop Detection

If the SAME check fails 3 times across attempts, **STOP**. Present:

- What I'm trying to accomplish
- What keeps failing (with error output)
- What I've tried
- My best theory on root cause
- Suggested next step (often: escalate to the full pipeline)

Do NOT keep retrying. Escalation is efficiency, not failure.

## Step 6 — Mechanical Validation

Run, in order:

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
  - `/commit` to commit the work
  - `/create-pr` if ready for review
  - `/my-review` if any self-review finding looks substantial

**Do NOT commit, push, or create PRs.** The hand-off IS the stopping point.

## Guidelines

- The tripwire is the safety net. Trust it. False alarms are cheap; false negatives are expensive.
- Self-review is a sanity check, not a quality gate. Recommend `/my-review` for non-trivial findings.
- Don't generate spec/plan/analysis files. If you find yourself wanting to, that's a tripwire signal — escalate.
- TDD discipline is non-negotiable. The fast lane skips planning ceremony, NOT correctness ceremony.
- One-pass means one pass. Don't re-implement after self-review unless I direct it.
- Never auto-commit. The hand-off is the stopping point.

## References

- `references/tripwire-signals.md` — escalation criteria
- `references/self-review-checklist.md` — the quick review pass

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
