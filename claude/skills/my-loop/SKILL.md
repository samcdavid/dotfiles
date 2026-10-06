---
effort: high
name: my-loop
description: "Interleave understanding and building in small inspected slices — understand, act, inspect, clarify, adjust — with one short living loop log for review and resume, then validate and review the result."
---

# My Loop

Deliver a change as a continuous conversation instead of a plan-then-execute
pipeline. Planning happens inside the work: each slice reads just enough code,
makes one small test-first change, shows the user what happened, and lets what
the code revealed steer the next slice. There is no planning phase, no spec, no
synchronized plan, and no pre-implementation gate.

The one artifact is the **loop log**: a short, human-readable record of the
current understanding, decisions, and slices. It exists so the user can review
what is happening at a glance and so a cleared context resumes exactly where it
stopped. It is rewritten to stay current, not appended into a document nobody
reads.

`my-workflow` remains the route for migrations, multi-issue or sibling-heavy
work, and anything the user wants planned up front. Hand off to it rather than
stretching this loop.

## Load Rules

Already loaded as memory under Claude Code — apply without re-reading:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/tdd-phase.md`
- `~/.claude/rules/human-readable-communication.md`

Under Codex, read the `~/.agents/rules/` equivalents explicitly. Always read
`references/protocol.md`; use `references/log-template.md` when creating a log.

## Loop

1. **Orient.** Find or create the branch-matched loop log. Read the request and
   only the code needed to state the goal and a first slice. Ask for the edit
   scope (goal plus paths) once; never edit before it is granted. Running any
   codegen (e.g. type generation) and fixing whatever blocks the pre-commit
   hook are always in scope, and land in the slice's commit.
2. **Slice.** Repeat until the user says the goal is met:
   understand → act (RED then GREEN) → inspect (show the diff and test result)
   → clarify (one question, only if this slice surfaced a user-owned decision)
   → adjust → commit locally → update the log.
3. **Validate.** Run `my-validate` in session mode once against the slices and
   the log. Stop and report.
4. **Review.** After the user continues, run `implement-review` standalone with
   the log as context. Record its outcome and render the final report.

Stop after every slice by default so the user steers. If the user says to keep
going, run slices back to back until a user-owned question, a scope change, a
failed check, or the goal is met. Never push, publish, create or update a PR,
deploy, or mutate remote state without an explicit request.

## Output

After each slice, return: what changed and why (one or two sentences), the key
diff hunk with file/line, the test command and result, the commit, what the
slice taught about the system, and either the next proposed slice or the single
question blocking it. Keep the log path visible. Do not reproduce raw
transcripts, full diffs, or passing logs. Lead with the actual change and
decision; never make the user decode slice numbers or log keys.
