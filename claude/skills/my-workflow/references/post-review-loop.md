# Post-Review Loop

Load after `my-review`.

If review findings remain, do not checkpoint. Dispatch `address-pr-feedback local` immediately with the exact findings, including their stable Finding Register keys and any reopen evidence, plus plan/base/ledger context and remaining shared review-pass budget. Its runner executes the bounded implement -> validate -> review -> repair sequence and returns its final review output; count that output against the workflow's same three-pass cap.

If the returned review is clean, converge. If substantive findings remain and budget exists, continue without a user stop; if the third combined pass still has substantive findings, stop and report the remaining findings, iteration deltas, and root-cause theory. Record iteration count, finding deltas, artifacts, and next resume command in the ledger.

`address-pr-feedback` appends its own per-round record and resolved/deferred Finding Register rows to the same ledger. Record the loop-level state above and let those rows stand for the round's detail — don't restate its verdict table or re-open unchanged settled findings.

If three resumed iterations fail to reduce findings meaningfully, stop and report remaining findings, iteration deltas, and root-cause theory.
