# Autonomous Loop Protocol

Detailed protocol for each phase of the iteration loop.

## Phase 1: Review

Before each iteration, build situational awareness:

1. Read current state of in-scope files (full context)
2. Read last 10-20 entries from results log
3. Read `git log --oneline -20` to see recent changes
4. Identify: what worked, what failed, what's untried

**Why read every time?** After rollbacks, state may differ from what you expect. Never assume — always verify.

## Phase 2: Ideate

Pick the NEXT change. Priority order:

1. **Fix crashes/failures** from previous iteration first
2. **Exploit successes** — if last change improved metric, try variants in same direction
3. **Explore new approaches** — try something the results log shows hasn't been attempted
4. **Combine near-misses** — two changes that individually didn't help might work together
5. **Simplify** — remove code while maintaining metric. Simpler = better
6. **Radical experiments** — when incremental changes stall, try something dramatically different

**Anti-patterns:**
- Don't repeat the exact same change that was already discarded
- Don't make multiple unrelated changes at once (can't attribute improvement)
- Don't chase marginal gains with ugly complexity

## Phase 3: Modify

- Make ONE focused change to in-scope files
- The change should be explainable in one sentence
- Write the description BEFORE making the change (forces clarity)

## Phase 4: Commit

```bash
git add <changed-files>
git commit -m "experiment: <one-sentence description>"
```

Commit BEFORE running verification so rollback is clean: `git reset --hard HEAD~1`

## Phase 5: Verify

Run the agreed-upon verification command. Capture output.

**Timeout rule:** If verification exceeds 2x normal time, kill and treat as crash.

**Extract metric:** Parse the verification output for the specific metric number.

## Phase 6: Decide

```
IF metric_improved:
    STATUS = "keep"
    # Do nothing — commit stays
ELIF metric_same_or_worse:
    STATUS = "discard"
    git reset --hard HEAD~1
ELIF crashed:
    # Attempt fix (max 3 tries)
    IF fixable:
        Fix -> re-commit -> re-verify
    ELSE:
        STATUS = "crash"
        git reset --hard HEAD~1
```

**Simplicity override:** If metric barely improved but change adds significant complexity, treat as "discard". If metric unchanged but code is simpler, treat as "keep".

## Phase 7: Log Results

Append to results log (TSV format):

```
iteration  commit   metric   delta   status   description
42         a1b2c3d  0.9821   +0.02   keep     increase attention heads from 8 to 12
43         -        0.9845   -0.01   discard  switch optimizer to SGD
44         -        0.0000   0.00    crash    double batch size (OOM)
```

## Phase 8: Repeat

Go to Phase 1. NEVER STOP. NEVER ASK IF YOU SHOULD CONTINUE.
