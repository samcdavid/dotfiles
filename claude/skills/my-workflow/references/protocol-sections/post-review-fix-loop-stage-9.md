## Post-Review Fix Loop

After `my-review`, inspect findings:

- **Converged**: zero Critical and zero substantive non-blocking findings -> workflow can move to final report.
- **Findings remain**: checkpoint with findings and wait for user to resume fixes.

On a resumed fix pass, run one iteration only:

1. `address-pr-feedback` with the most recent review findings.
2. `my-validate` against the same plan.
3. `my-review` against the same base branch and full lens set.

Stop after that review output. Do not run a second fix iteration in the same context unless the user explicitly asks. Update the ledger with iteration count, finding deltas, remaining findings, and exact resume command.

If three resumed iterations do not reduce findings meaningfully, stop and surface root-cause theory instead of continuing.
