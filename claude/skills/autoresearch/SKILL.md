---
name: autoresearch
description: Autonomous goal-directed iteration loop. Modify, verify mechanically, keep or rollback, repeat. Runs until interrupted. Invoke manually when you want to iterate on a measurable goal (tests, benchmarks, coverage, build size, etc).
disable-model-invocation: true
---

# Autoresearch — Autonomous Goal-Directed Iteration

Inspired by Karpathy's autoresearch. Constraint-driven autonomous iteration: modify, verify, keep/discard, repeat forever.

## Getting Started

Determine what to iterate on:

1. **If `$ARGUMENTS` specifies a goal**: use that as the iteration target.
2. **If the session has active context** (a plan in progress, recent conversation about a problem, failing tests, a performance issue): propose an iteration target derived from that context. State your understanding and get confirmation before starting.
3. **Otherwise**: ask the user what they want to iterate on. Don't guess.

Once you have a target, run the Setup Phase. Do NOT begin the loop until setup is confirmed.

## Setup Phase

1. **Read all in-scope files** for full context before any modification.
2. **Define the goal and metric** — What does "better" mean? Extract or agree on a single mechanical metric:
   - Tests pass + coverage %
   - Benchmark time (ms)
   - Build succeeds + warnings eliminated
   - File/bundle size reduced
   - Lighthouse/accessibility score
   - Lines of code reduced (while tests pass)
   - If no metric exists, define one with the user. It MUST be verifiable by a command.
3. **Define the verify command** — The exact shell command that produces the metric. Write it down.
4. **Define scope constraints** — Which files can you modify? Which are read-only?
5. **Define metric direction** — Higher is better or lower is better?
6. **Create the results log** — See `references/results-logging.md`.
7. **Establish baseline** — Run verification on current state. Record as iteration 0.
8. **Present setup to user** — Show: goal, metric, verify command, scope, direction, baseline value. Get confirmation before starting the loop.

## The Loop

Read `references/autonomous-loop-protocol.md` for full protocol details.

```
LOOP FOREVER:
  1. Review: Read current state + git history + results log
  2. Ideate: Pick next change based on goal, past results, what hasn't been tried
  3. Modify: Make ONE focused change to in-scope files
  4. Commit: Git commit the change (before verification)
  5. Verify: Run the mechanical metric
  6. Decide:
     - IMPROVED -> Keep commit, log "keep"
     - SAME/WORSE -> Git revert, log "discard"
     - CRASHED -> Try to fix (max 3 attempts), else log "crash" and revert
  7. Log: Record result in results log
  8. Repeat: Go to step 1. NEVER STOP. NEVER ASK "should I continue?"
```

## Critical Rules

1. **NEVER STOP** — Loop until manually interrupted. The user may be away.
2. **Read before write** — Always understand full context before modifying.
3. **One change per iteration** — Atomic changes. If it breaks, you know exactly why.
4. **Mechanical verification only** — No subjective "looks good". Use the metric.
5. **Automatic rollback** — Failed changes revert instantly. No debates.
6. **Simplicity wins** — Equal results + less code = KEEP. Tiny improvement + ugly complexity = DISCARD.
7. **Git is memory** — Every kept change committed. Read history to learn patterns.
8. **When stuck, think harder** — Re-read files, re-read goal, combine near-misses, try radical changes. Don't ask for help unless truly blocked by missing access/permissions.
9. **Brief status every 5 iterations** — One line: iteration number, current metric, keeps/discards count.

## Minimal-Change Strategies

| Strategy | When to use |
|---------|-------------|
| **Extract helper** | Shared logic causes a cycle or duplication; extract to a new module |
| **Move code down** | Move a function to break a dependency direction |
| **Invert dependency** | Replace direct call with callback, option, or data structure |
| **Simplify** | Remove code while maintaining metric — simpler is always better |
| **Combine near-misses** | Two individually-failed changes might work together |
| **Radical experiment** | When incremental changes stall, try something dramatically different |

## Stuck Protocol

If >5 consecutive discards:

1. Re-read ALL in-scope files from scratch
2. Re-read the original goal
3. Review entire results log for patterns
4. Try combining 2-3 previously successful changes
5. Try the OPPOSITE of what hasn't been working
6. Try a radical architectural change
