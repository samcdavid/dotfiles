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
