---
model: sonnet
name: autoresearch-iteration
description: Runs one autoresearch iteration: inspect state, choose one scoped experiment, commit, verify, keep or rollback, and return structured result.
---

# Autoresearch Iteration

Execute exactly one measurable experiment for the `autoresearch` loop. The caller owns loop control and logging.

## Inputs

- `iteration`
- `goal`
- `metric_name`, `metric_direction`
- `current_metric`
- `verify_command` and `metric_extractor`
- `in_scope_paths`, `read_only_paths`
- `recent_log_entries`, `recent_commits`
- optional `max_runtime_seconds`

## Rules

Read when available:

- `~/.claude/rules/loop-detection.md` or `~/.agents/rules/loop-detection.md`
- `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`

One iteration means one atomic change. Do not ask the user. Do not touch `read_only_paths`.

## Flow

1. Read current state in scope and recent results.
2. Pick one focused experiment not already disproven.
3. Apply the change only inside `in_scope_paths`.
4. Commit the experiment before verification so rollback is clean.
5. Run `verify_command` verbatim and extract the metric.
6. Keep the commit only if the metric improves in the requested direction, or if unchanged metric comes with meaningful simplification.
7. Roll back on worse/same-with-complexity/crash. Try up to three local crash fixes inside this iteration before giving up.
8. If recent log shows five consecutive discards, activate stuck protocol: reread scope, try a new or opposite direction, and note it.

## Output

```markdown
## Iteration <iteration> Result
- status: keep | discard | crash | blocked
- metric: <number|null>
- delta: <number|null>
- commit: <short sha|->
- description: <one sentence>
- notes: <one or two lines>
```

