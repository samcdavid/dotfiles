## Step 5 — Write the Phase Slices (behavioral track)

Plan each behavioral fix as **one phase = one fix**, following `my-plan`'s sizing discipline: a single bounded behavior, the smallest set of files (ideally one production file + its test), completable by a subagent that sees only this slice. PR fixes are already granular; if one "fix" bundles several behaviors, split it into ordered phases.

For each phase, define the slice the `implementation-executor` consumes (see the agent's `## Inputs`):

- `phase_name` / `phase_overview` — the reviewer's concern and what correct behavior looks like
- `red_tests` — the failing test(s) that encode the corrected behavior (paths + what each asserts)
- `green_changes` — the production change(s) that make them pass (paths + descriptions)
- `success_criteria` — **mechanical** (runnable/greppable), RED first (test exists and FAILS) then GREEN (test PASSES) plus any check
- `allowed_paths` — the file(s) this fix may touch + their tests
- `verification_commands` — how to run tests/checks in this stack (derive from the project's Makefile/justfile/CI or Step 9's command list; see `my-implement`'s `references/verification-commands.md`)
- `architectural_constraints` — boundaries the fix must not violate (layer boundaries, dependency direction, naming) — draw from the Fix Quality Bar below
- `working_context` — cwd, stack, and **any relevant gotcha** (e.g. Elixir multi-clause grouping, concurrent-index DSL) so the executor doesn't rediscover it the hard way

Create a TodoWrite list: one todo per behavioral phase, one todo per direct-edit phase.

### Fix Quality Bar (from `my-review`)

These are the standards every fix — executor phase or direct edit — must meet. Encode the relevant ones as `architectural_constraints` in each slice, and apply them yourself when re-verifying (Step 6) and on direct edits.

**Correctness** — fix addresses the reviewer's *actual* concern; edge cases covered (for every conditional/pattern match touched, what else could the value be?); appropriate bang vs. non-bang; no lazy imports; Oban uniqueness/transaction config still correct; when adding a clause to a multi-clause Elixir function, all clauses of that name/arity stay grouped (`--warnings-as-errors` fails otherwise).
**Layer boundaries** — no API/resolver concerns leaked into contexts (or vice versa); extracted helpers live at the right layer.
**Migration safety** (if touched) — NOT NULL safe for table size; correct column types (money = `numeric(16,2)`, JSONB defaults); down migration present; concurrent index ops use the Ecto DSL (not raw SQL) with `concurrently: true` on **both** `up` and `down` under `@disable_ddl_transaction true`.
**Tests** — behavior changes have updated tests; tests at the right level (unit for branching, integration for wiring); assertions specific, not vacuous.
**Lint discipline** — no checks disabled/suppressed; no formatter violations; no new warnings.
**Existing patterns** — reuse existing utilities; if the reviewer pointed you to a function, actually use it.

Present the fix plan to the user — the behavioral phases (with what each RED test will assert) and the direct-edit list — and get a quick confirmation of the approach before executing. The triage was already approved in Act I; this confirms *how* you'll fix, not *whether*.

---

# Act III — Implement (condensed `my-implement`)

Execute the plan **one phase at a time, sequentially**. You are the orchestrator: dispatch, re-verify, own loop detection. Apply blocking feedback before non-blocking.
