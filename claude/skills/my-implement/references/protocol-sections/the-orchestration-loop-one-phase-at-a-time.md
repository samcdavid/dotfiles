## The orchestration loop — one phase at a time

For each unchecked phase, in order:

### 1. Assemble the phase slice

Pull from the plan **only what this phase needs** — do not pass the whole plan or the whole repo. Each executor should run in a small context (target **under ~50k tokens**); a phase that can't fit that is too big and should be split. Note this is a *budget you enforce by scoping*, not a hard cap the harness imposes — so size the slice deliberately. The slice:

- `phase_name`, `phase_overview`
- `red_tests` — the phase's "Tests First (RED)" list
- `green_changes` — the phase's "Changes Required (GREEN)" list
- `success_criteria` — the phase's mechanical success criteria (RED ones first, then GREEN/checks)
- `allowed_paths` — the files/dirs this phase may touch (derive from the change list)
- `verification_commands` — how to run tests/checks in this stack (see `references/verification-commands.md`)
- `architectural_constraints` — the plan's constraints relevant to this phase
- `working_context` — cwd, stack, any setup notes

If a phase lacks a "Tests First (RED)" section, **stop and ask** — the plan needs updating before this phase can run. TDD is not optional.

### 2. Dispatch one executor

Spawn the `implementation-executor` agent with the slice. **One at a time** — never run two executors in parallel; they share the working tree and the plan's phase order encodes dependencies. Let it finish before you do anything else.

### 3. Re-verify independently (you are not the implementer)

When the executor returns its report, **do not take it on faith**. As the reviewer-not-implementer, confirm two things: that the mechanical checks pass, and — the real goal — that the implementation actually **matches the requirements this phase was given**.

1. **Re-run the phase's mechanical `success_criteria`** yourself and read the diff the executor produced.
2. **Check requirements conformance against the slice you handed it.** Read the executor's "Requirements Conformance" table, then verify it against the diff: does the code satisfy `phase_overview` and every behavioral expectation, fully? Do the tests genuinely exercise the requirement, or are they vacuous? Was anything in the brief silently dropped or reinterpreted? Green tests that don't actually encode the requirement do **not** count as done.

- All criteria pass, the diff stays within `allowed_paths`, AND the implementation meets the phase's requirements → the phase is genuinely done.
- A criterion fails, the diff touched files it shouldn't have, the executor returned `ESCALATE`, OR the work doesn't conform to the requirements (even with green tests) → go to Loop Detection (re-dispatch with a brief that names the specific gap).

Before declaring a Python phase green where it involves a dependency pin, lockfile change, or fresh-install behavior **inside a git worktree**: apply the **Worktree `.venv/bin/*` shebangs** gotcha. A `uv run pytest` can silently run via a sibling worktree's interpreter if the entry-point shebang snapshotted it at venv creation. Check `head -1 .venv/bin/pytest`; if it points outside this worktree, `rm -rf .venv && uv sync` and re-run, or `uv run --no-active python -m pytest ...`.

### 4. Record and advance

On a verified-done phase:
1. Mark the phase's RED, GREEN, and Success-Criteria checkboxes `[x]` in the plan file.
2. Update the todo to completed.
3. Move to the next phase.

Maintain FORWARD MOMENTUM. Don't re-open finished phases, don't gold-plate, don't let an executor wander beyond its slice.
