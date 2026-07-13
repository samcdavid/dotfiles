## Step 5 — Mitigation and fix (user-driven)

Separate MITIGATION (stop the bleeding) from FIX (prevent recurrence). Both are the user's call — surface options, do not take them.

- **Mitigation options** — rollback, feature flag toggle, config change, scale-up, re-run CI job, skip flaky test. List options the user can choose from. Do NOT execute any of them yourself.
- **Long-term fix** — code change, architecture improvement, process change, flaky test stabilization. Surface the candidate; the user decides whether to implement now or schedule it.

If the user asks you to implement the long-term fix, switch to the appropriate skill (`my-implement`, `my-plan`) — do not implement from inside this investigation flow.
