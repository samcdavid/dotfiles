---
name: autoresearch
description: Autonomous goal-directed iteration loop. Modify, verify mechanically, keep or rollback, repeat. Runs until interrupted or iteration limit reached. Invoke manually when you want to iterate on a measurable goal (tests, benchmarks, coverage, build size, etc). Optional iteration limit as argument (e.g. /autoresearch 100). Delegates each iteration's work to the `autoresearch-iteration` agent so the main loop holds only structured results.
disable-model-invocation: true
---

# Autoresearch — Autonomous Goal-Directed Iteration

Inspired by Karpathy's autoresearch. Constraint-driven autonomous iteration: modify, verify, keep/discard, repeat. The main loop owns control, the results log, and limit checking; each iteration's read-modify-verify work runs inside the `autoresearch-iteration` agent so the main window stays small even across long runs.

## Step 1 — Parse arguments

`$ARGUMENTS` may contain an optional iteration limit and/or a goal description.

- If `$ARGUMENTS` starts with a number (e.g. `100`, `50`), treat it as the **iteration limit**. The rest (if any) is the goal.
- If `$ARGUMENTS` is only a number, use the iteration limit but determine the goal from context (see below).
- If `$ARGUMENTS` has no number, there is no iteration limit — loop forever.

Examples: `/autoresearch 100` = 100 iterations, goal from context. `/autoresearch 50 improve test coverage` = 50 iterations, goal is "improve test coverage". `/autoresearch reduce bundle size` = no limit, goal is "reduce bundle size".

## Step 2 — Determine the goal

1. If `$ARGUMENTS` specifies a goal, use it.
2. Otherwise, if the session has active context (a plan in progress, recent conversation about a problem, failing tests, a performance issue), propose a target derived from that context. State your understanding and get confirmation before starting.
3. Otherwise, ask the user what to iterate on. Don't guess.

## Step 3 — Setup phase

Before any iteration runs:

1. **Define the metric** — what does "better" mean? A single mechanical metric verifiable by a command. Examples:
   - Tests pass + coverage %
   - Benchmark time (ms)
   - Build succeeds + warnings eliminated
   - File/bundle size reduced
   - Lighthouse / accessibility score
   - Lines of code reduced (while tests pass)
   If no metric exists, define one with the user. It MUST be extractable from command output.
2. **Define the verify command** — the exact shell command that produces the metric. Write it down. The agent uses it verbatim.
3. **Define the metric extractor** — regex or one-line instruction for pulling the numeric metric from the verify command's output.
4. **Define scope constraints** — `in_scope_paths` (modifiable) and `read_only_paths` (off-limits).
5. **Define metric direction** — `higher_is_better` or `lower_is_better`.
6. **Create the results log** — see `references/results-logging.md`.
7. **Establish baseline** — run the verify command on the current state. Record as iteration 0.
8. **Present setup to user** — show: goal, metric, verify command, metric extractor, scope, direction, baseline value, iteration limit (or "unlimited"). Get confirmation before starting the loop.

## Step 4 — The loop

```
LOOP (until iteration limit reached, or forever if no limit):

  1. Build iteration inputs from current state:
     - iteration: next integer
     - goal, metric_name, metric_direction, verify_command, metric_extractor
     - in_scope_paths, read_only_paths
     - recent_log_entries: last 10-20 entries from the results log (read from disk)
     - recent_commits: `git log --oneline -20` output
     - baseline_metric: iteration 0's value
     - current_metric: the latest kept iteration's value (or baseline if no keeps yet)

  2. Spawn the `autoresearch-iteration` agent with the bundle.

  3. The agent returns one Iteration Result block (status: keep | discard | crash | blocked, plus metric, delta, commit, description, notes).

  4. Append the result to the results log (in the format defined in references/results-logging.md).

  5. Handle the status:
     - keep: do nothing (the agent's commit stays); update current_metric
     - discard: do nothing (the agent already reverted)
     - crash: do nothing (the agent already reverted)
     - blocked: STOP the loop. Surface the agent's notes to the user. Wait for direction.

  6. Print a one-line status every 5 iterations: "iter N — metric M — keeps:K discards:D crashes:C".

  7. If iteration limit set and reached: print the final summary and STOP.

  8. Otherwise repeat from step 1. NEVER ASK "should I continue?".
```

## Step 5 — Final summary

When the loop ends (limit reached or blocked or user-interrupted), produce:

```
## Autoresearch Final Summary

- Goal: <goal>
- Metric: <metric_name> (<metric_direction>)
- Baseline: <baseline_metric>
- Final: <current_metric>
- Delta: <final − baseline>
- Iterations: <total> (keeps: K, discards: D, crashes: C)
- Best iteration: #<iter> — <description>
- Worst pattern: <if any pattern stood out — e.g. "5 consecutive discards triggered Stuck Protocol on iter 42">
- Recommendations: <1-2 lines on what to try next manually, if applicable>
```

## Constraints

- **NEVER STOP** (unless iteration limit reached, agent returns `blocked`, or user interrupts) — the user may be away.
- **NEVER ASK** the user mid-loop. If genuinely stuck, the agent returns `blocked` and the loop halts.
- **Git is memory** — every kept change is committed. The agent reads `git log` to learn patterns.
- **Mechanical only** — the verify command is the only judge. Subjective "looks good" is not used.
- **Read-only paths are absolute.** If the agent reports it touched one, the iteration was already auto-discarded.

## References

- `references/autonomous-loop-protocol.md` — detailed per-phase protocol (the agent reads this when needed).
- `references/results-logging.md` — results log format and location.
