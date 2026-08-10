# Gotchas — address-pr-feedback

Known failure patterns and lessons learned. Read before starting work with this skill.

### Elixir multi-clause function grouping broken by interleaved helpers
- **Category:** failure-mode
- **Context:** When adding a new clause to an existing multi-clause function (e.g. a catch-all or pattern-match clause), and also adding an unrelated helper function in the same edit
- **Wrong:** Inserting a new function definition (`def helper/1`) between existing clauses of the same function (`def error_message/1`), producing interleaved definitions
- **Right:** Keep all clauses of the same function/arity grouped together. Place any new helper functions before or after the entire group, never inside it
- **Why:** Elixir emits a "clauses with the same name and arity should be grouped together" warning for interleaved function definitions. With `--warnings-as-errors` (standard CI config) this fails compilation. The formatter may also reorder things in a way that makes the grouping violation non-obvious until compile time.
- **Source:** Observed when adding a `%Ecto.Changeset{}` clause to a view helper alongside extracting an SVG function component in the same file

### Brand/product name capitalisation in user-visible copy
- **Category:** convention
- **Context:** Writing or editing user-visible strings in templates — error messages, labels, button copy, scope descriptions, alt text
- **Wrong:** Using lowercase product name (e.g. `brandname`) in body copy when the correct brand form is capitalised (`BrandName`)
- **Right:** Check the correct capitalisation for any product or brand name appearing in copy before writing it. When in doubt, grep for existing uses in the codebase rather than guessing
- **Why:** Brand names have prescribed capitalisation that differs from standard English title case. Getting it wrong in user-facing copy requires a follow-up fix and a re-review round
- **Source:** Observed when writing scope description and account copy in an OAuth consent page template

### Ecto concurrent index migrations: use DSL, not raw SQL
- **Category:** anti-pattern
- **Context:** Writing Ecto migrations that drop or create indexes concurrently (requires `@disable_ddl_transaction true`)
- **Wrong:** `execute "DROP INDEX CONCURRENTLY IF EXISTS my_index_name"` — triggers credo's `Raw sql executed` check
- **Right:** `drop_if_exists index(:table_name, [:col1, :col2], concurrently: true)` — uses the Ecto migration DSL, passes credo
- **Why:** Credo enforces no raw SQL in migrations. The Ecto DSL has full support for concurrent index operations and resolves the index name automatically from column list, or accepts an explicit `name:` option for named indexes
- **Source:** Migration that replaced a raw `execute "DROP INDEX CONCURRENTLY..."` to fix credo CI failure

### Approval review body may contain questions or sanity-check requests — read it fully
- **Category:** failure-mode
- **Context:** When gathering PR feedback and a reviewer has submitted an APPROVE state review
- **Wrong:** Treating an APPROVE review as "no action needed" and skipping the body text — only scanning `state: APPROVED` and moving on
- **Right:** Read the full body of every review, regardless of state. APPROVE reviews frequently contain inline questions, non-blocking sanity checks, design confirmations, or follow-up notes that still need a response.
- **Why:** GitHub's review state (APPROVE / COMMENT / REQUEST_CHANGES) indicates merge readiness, not whether the reviewer has questions. Approving reviewers often leave "this looks good, but did you consider X?" or "worth confirming before merge" notes that go unaddressed if only the state is checked.
- **Source:** Observed when a reviewer submitted an APPROVE containing a specific question about docstring clarity that was missed because only the review state was checked

### Ecto concurrent index migrations: both `up` and `down` need `concurrently: true`
- **Category:** edge-case
- **Context:** Writing `up`/`down` for a migration that uses `@disable_ddl_transaction true` for concurrent index operations
- **Wrong:** Only adding `concurrently: true` to index operations in `up`, leaving `down` without it
- **Right:** Every `drop_if_exists`, `create_if_not_exists`, `create`, and `drop` for indexes in BOTH `up` and `down` must include `concurrently: true` when `@disable_ddl_transaction true` is set
- **Why:** Credo's migration checks scan all clauses, not just `up`. A non-concurrent index op in `down` while the module declares `@disable_ddl_transaction true` triggers `Index not concurrently` warnings
- **Source:** Migration `down` function that was missing `concurrently: true` on its `drop_if_exists` call, caught by credo CI

### Don't re-request review from someone who already approved
- **Category:** failure-mode
- **Context:** Step 13, after pushing fixes for review feedback. Reviewers have approved, and their approvals now predate the new commits.
- **Wrong:** Re-requesting review from every prior reviewer because "the approvals are stale," including the ones whose state is APPROVED. `gh api .../requested_reviewers -X POST -f 'reviewers[]=<approver>'`
- **Right:** Re-request only from reviewers who left REQUEST_CHANGES, or who have unresolved substantive threads and have *not* approved. For an approver, the thread reply IS the notification — they get it, and they re-review if they care. Never re-request from someone whose latest state is APPROVED.
- **Why:** It puts an already-satisfied reviewer back into "Awaiting your review" in their dashboard and inbox, re-pinging them for a PR they already signed off. It also destroys the signal of who actually still owes a review — the pending list stops meaning anything. And on any repo with `dismiss_stale_reviews` branch protection, re-requesting **dismisses the existing approval outright**, converting a mergeable PR into a blocked one. Verified on the PR below that the approvals survived (`reviewDecision` stayed `APPROVED`), so the dismissal risk is config-dependent — but the queue pollution is unconditional.
- **Source:** MCP-650 / PR #27839 — re-requested all three approvers after round 2 and again after round 3, leaving five names pending on a PR whose review decision was already APPROVED.
