## Pipeline Exact Order

| # | Stage | Consumes | Produces | Checkpoint |
|---|---|---|---|---|
| 1 | `my-research` | task / ticket | research doc | stop |
| 2 | `my-spec` | research + task | spec | stop |
| 3 | `my-clarify` | spec | clarified spec | stop |
| 4 | `my-plan` | spec + research | plan | stop |
| 5 | `my-observe` | plan | observability companion | stop |
| 6 | `my-analyze` | research + spec + plan | consistency report | stop |
| 7-9 | gated atomic block: `my-implement` -> `my-validate` -> `my-review` | approved plan + completed stage 1-6 ledger | code changes, validation report, review verdict | stop after review |
| 9+ | post-review loop iteration: `address-pr-feedback` -> `my-validate` -> `my-review` | review findings | fixes, validation, new review verdict | stop after review |

Track stages in the ledger. Mark each `in_progress` when it starts and `completed` when output exists. A checkpoint is an intentional stop, not a blocker.

The single `my-review` stage replaces separate `requirements-audit`, `security-audit`, `my-arch-review`, `perf-review`, and `quality-audit` runs; lens reviewers read those skills' criteria as source truth. Invoke a standalone deep audit only when the review finding warrants a focused follow-up.
