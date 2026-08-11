# Post-Review Loop

Load after `my-review`.

If review findings remain, checkpoint and wait for the user to resume fixes. On a resumed fix pass, run exactly one iteration:

1. `address-pr-feedback` with exact findings.
2. `my-validate`.
3. `my-review`.

Stop after the new review output, even if findings remain. Record iteration count, finding deltas, artifacts, and next resume command in the ledger.

`address-pr-feedback` appends its own per-round record (verdict table, lessons, deferrals) to the same ledger. Record the loop-level state above and let that section stand for the round's detail — don't restate its verdict table.

If three resumed iterations fail to reduce findings meaningfully, stop and report remaining findings, iteration deltas, and root-cause theory.
