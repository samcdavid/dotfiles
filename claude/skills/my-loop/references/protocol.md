# Protocol — my-loop

`my-loop` interleaves planning and building. Each slice is a full
understand → act → inspect → clarify → adjust cycle, and the loop log is the
only durable artifact: the user's review surface and the resume source of
truth.

## Governing constraints

1. **No planning phase.** Do not produce a spec, phased plan, test strategy
   document, or architecture write-up before the first slice. Do not dispatch
   `my-pair-plan`, `my-plan`, `my-spec`, or `my-implement` — they assume a plan
   this loop deliberately does not have.
2. **Understand just enough.** Read the code needed for the next slice, not the
   whole surface. Use a focused read-only agent only when one concrete
   uncertainty blocks the next slice.
3. **One explicit scope grant.** Before the first edit, state the goal and the
   paths you expect to touch, and wait for the user to grant them. Editing
   outside the granted paths, or changing the goal, needs a fresh grant. Never
   infer implementation permission. Two kinds of edit are always in scope,
   wherever the files live, because they are a mechanical consequence of an
   already-granted edit rather than new work:
   - **Codegen** — running any project generator (types, schemas, API clients,
     and the like) and the files it rewrites. Generated files are never
     hand-edited, and a migration generator is not codegen here — it still
     routes per constraint 9.
   - **Pre-commit unblocking** — whatever fix the project's pre-commit hook
     needs before the slice's commit can land (formatting, lint, type errors
     the slice caused). This overrides `Skill(commit)`'s stop for hook-flagged
     files outside the commit. Never bypass the hook with `--no-verify`; stop
     and report if the fix would change behavior beyond the slice's goal, or
     after the third same-root failure.
4. **Slices are small and test-first.** A slice proves one behavior: RED, then
   the minimum GREEN, then the narrowest check that can disprove it. Pure
   refactors or config edits that cannot be tested behaviorally say so and
   name the mechanical check used instead.
5. **The user inspects every slice.** Show the change, the evidence, and what it
   taught before moving on. In `pace: step` (default), end the turn after every
   slice. In `pace: run`, continue only until a stop condition below.
6. **Clarify only what the code surfaced.** Resolve facts from code and docs.
   Ask a user-owned decision only when the current slice made it concrete; ask
   one at a time with a recommendation and its consequence.
7. **The log stays short and current.** Rewrite `Current Understanding` and
   `Next` every slice rather than appending to them. Decisions and slices are
   one-line or four-line entries. If the log reads like a spec, it has drifted.
8. **Commit each verified slice.** Commit locally through `Skill(commit)`, scoped
   to that slice's files plus any codegen output and pre-commit fixes it
   needed, so the change and its mechanical follow-ups never land in separate
   commits. A slice that
   failed its check stays uncommitted for inspection.
9. **Know when to leave.** Migrations, persisted schema/data changes,
   multi-issue or sibling-coordinated work, or a request for an up-front plan
   route to `my-workflow`. Record the reason in the log and hand the user
   `/my-workflow`; do not continue the loop.
10. **No outward actions.** Pushes, PR mutations, published messages,
    deployments, and other remote changes require an explicit request.

## Step 0 — Find or create the log

Run `git branch --show-current` first.

- On a feature branch, a loop log under `~/.thoughts/loops/` whose `branch`
  matches is authoritative; resume it. Never create a second log for that
  branch unless the user explicitly replaces the first.
- On `main`/`master` or with no match, fall back to Linear ID, slug, then topic.
- If a `my-workflow` ledger under `~/.thoughts/workflows/` already matches the
  branch, say so and ask which flow the user wants before creating a log.

Create new logs at `~/.thoughts/loops/<issue-or-topic-slug>.md` from
`log-template.md`. Loops live outside `~/.thoughts/workflows/` so `my-workflow`
never mistakes a loop log for its ledger.

## Step 1 — Orient and get scope

Read the request (and Linear issue if given — record only the need and a source
link, never copied issue prose). Read just enough code to write a first
`Current Understanding`, a goal, the expected paths, and a first slice.

Present those four things with the most relevant current-code excerpt
(clickable file/line) and ask for the scope grant. Record the grant
(`scope_goal`, `scope_paths`, `scope_granted_at`, `status: looping`) only on an
explicit yes. End the turn.

## Step 2 — Slice

For each slice:

1. **Understand.** Read the code the slice touches. Note anything that
   contradicts `Current Understanding`.
2. **Act.** Write the failing test, prove it fails for the intended reason,
   write the minimum change, and run the narrowest disproving check.
3. **Inspect.** Gather the key diff hunk, check command and result, and what the
   slice taught.
4. **Clarify.** If the slice surfaced a user-owned decision, prepare one
   question with a recommendation. Otherwise propose the next slice.
5. **Adjust.** Rewrite `Current Understanding` and `Next`; add any decision.
6. **Commit** the verified slice, then append its `Slices` entry with the SHA.

Update `updated` in frontmatter, then present the slice per the SKILL.md output
contract.

Stop conditions (end the turn even in `pace: run`): a user-owned question, a
needed path or goal outside the grant, a failed check after the loop-detection
retries, a `my-workflow` routing trigger, the context-checkpoint budget, or the
goal appearing met. When the goal appears met, say so and ask whether to
validate or keep slicing.

The user can switch pace at any time; record it in frontmatter.

## Step 3 — Validate

On the user's go-ahead, set `status: validating` and dispatch `my-validate` in
session mode:

```yaml
mode: session
base_ref: <base_branch>
artifact_inputs:
  loop_log: <log path>
stage: loop_validation
authority: local_only
```

Do not pass the log as `plan_path`; it is not a plan with success criteria.
Record checks, repairs, residual risks, and the outcome under `Validation` and
in `validation`. A failed result returns to Step 2 with the failure as the next
slice. On a pass, stop and report — the log carries the state, so a cleared
context resumes into Step 4.

## Step 4 — Review

After the user continues, set `status: reviewing` and dispatch
`skill-implement-review` in `standalone` mode with no `plan_path`, the log as
requirements/decision context, `base_ref`, and local-only authority. It owns its
review → repair → validate loop and five-pass cap; do not interleave slices.

Record its terminal status, repairs, and surviving findings (full problem and
fix) under `Review`, set `review` and `status: done` (or `blocked`), and
render the final report: goal, slices with commits, decisions, validation and
review outcomes, residual risks, and any outward action the user may want next.

## Resume rules

Read the log first and route from frontmatter:

- `orienting` or no `scope_granted_at` → Step 1;
- `looping` → present `Current Understanding` and `Next`, then continue Step 2;
- `validating` with `validation` not passed → Step 3;
- `validation: passed`, review not terminal → Step 4;
- `done` → final report;
- `blocked` → restate the blocker and ask how to proceed.

Before resuming a slice, compare `git log` since the last recorded slice SHA
with the log. Record any unlogged commits rather than silently trusting either
source. Never infer state from conversation memory.
