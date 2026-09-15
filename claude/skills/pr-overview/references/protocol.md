# Category Detection Heuristics

These are starting heuristics, not an exhaustive spec — the point is to catch the common shapes cheaply from a diff, not to build a static-analysis tool. When a hunk is ambiguous, use judgment from surrounding code rather than skipping it.

## Product requirement changes

- Changed literal thresholds, limits, or magic numbers in business logic (`MAX_*`, `*_LIMIT`, percentage/rate constants).
- Changed validation rules: added/removed a required field, changed a regex/format check, changed an allowed-values list.
- Changed permission/role/authorization checks that alter who can do what.
- Changed user-facing copy tied to a rule (error messages, tooltips) when the surrounding logic also changed — copy-only changes with no logic change are not a requirement change.

## Modified existing tests

- Diff touches a file matching `*_test.*`, `*_spec.*`, `test_*.py`, `__tests__/`, `spec/` etc., where the file already existed before the diff (not a new test file).
- Within that, distinguish: assertion value/condition changed (behavior expectation changed) vs. mechanical refactor (rename, setup/teardown, formatting) — call out the former more prominently.

## New database migrations

- New files under conventional migration directories (`db/migrate/`, `migrations/`, `alembic/versions/`, `prisma/migrations/`, `ecto/priv/repo/migrations/`).
- New Alembic/Rails/Django/Ecto migration classes/modules.
- ORM model changes (new/removed/retyped field on a model/schema class) that imply a migration should exist — flag if no matching migration file appears in the same diff, since that's a common miss worth surfacing.

## Function/method signature changes

- Diff hunk touches a `def`/`function`/method declaration line itself (not just its body): parameter added/removed/reordered, type annotation changed, default value changed, return type changed.
- Language-agnostic tell: the changed line contains a parameter list `(...)` and is a declaration, not a call site.

## Public interface changes

- Exported symbols: `export`, `public`, `pub fn`, top-level classes/functions in a module's `__init__.py`/`index.ts` barrel file, or anything re-exported.
- API route/controller definitions: new/removed/changed HTTP route, GraphQL field/resolver, gRPC/protobuf service method.
- Changes to a versioned public contract file (OpenAPI/Swagger spec, `.proto`, GraphQL schema `.graphql`).

## Branching-condition changes

- Diff touches an `if`/`elif`/`else if`/`case`/`switch`/`when`/guard-clause line's condition expression (not just the body under it).
- Especially flag conditions that change which branch executes for existing inputs (tightened/loosened comparison, flipped boolean, added/removed `&&`/`||` clause) versus purely added new branches for new inputs.

## Feature flag use

- New flag check introduced: calls like `flag_enabled?`, `feature?`, `ld_client.variation`, `unleash.isEnabled`, `if os.environ.get("FEATURE_...")`, config-driven `flags.yaml`/`flags.json` entries.
- Existing flag check removed (flag being retired/cleaned up) — note this distinctly from a new flag being added, since cleanup and new-gating carry different review attention.
- Changed flag default/rollout percentage in a config file.

# Review Activity Summary

Applies only in PR mode. Use the GraphQL `reviewThreads` query already defined in `pr-cost-control.md` — it returns `isResolved`/`isOutdated` per thread and each comment's author, so no separate REST call for review state is needed. Pair it with `gh api repos/{owner}/{repo}/pulls/{N}/reviews --jq '[.[] | {user: .user.login, state, submitted_at}]'` for each reviewer's formal review state (`APPROVED`, `CHANGES_REQUESTED`, `COMMENTED`, `PENDING` — drop `PENDING`, it's not yet visible to others).

- **Per-reviewer state**: group reviews by `user.login`, keep only the review with the latest `submitted_at` per reviewer — an earlier `CHANGES_REQUESTED` followed by a later `APPROVED` from the same person means they approved, full stop.
- **Unresolved threads**: count `reviewThreads` entries where `isResolved: false` and `isOutdated: false`. An outdated thread (the diff moved past it) is not "still open" in a meaningful sense — mention it only if the count of genuinely unresolved current threads is zero and outdated ones exist, so the user isn't misled into thinking there's no discussion at all.
- **Leaning read**: this is a factual summary of the vote/thread counts, not a prediction. Phrase it as "N approvals, M change-requested, K unresolved threads" and only add a one-clause plain-language gloss ("trending toward merge" / "still has open concerns") when the counts make it unambiguous. If reviewers are split or there's only `COMMENTED` activity with no formal state, say that plainly instead of forcing a lean.
- A reviewer who commented but never submitted a formal review (no `APPROVED`/`CHANGES_REQUESTED`/`COMMENTED` review object, just inline comments) counts toward thread/comment activity but not toward the approval tally — note them separately if their comments raise substantive concerns.

## Comment-Stated Verdicts

Some automated reviewers post their verdict as text inside a plain issue/PR comment or review-thread comment instead of submitting a real GitHub review event, so `gh api .../reviews`'s `state` field never reflects them. Read the body of every comment returned by the `reviewThreads` query and by `gh api repos/{owner}/{repo}/issues/{N}/comments`, not just each comment's GitHub-level type:

- Look for the review-event vocabulary appearing as text in the comment body — `APPROVE`/`APPROVED`, `REQUEST_CHANGES`/`CHANGES_REQUESTED`, `COMMENT`/`COMMENTED` — typically near the start of the comment or in a bolded/heading line (e.g. `**Verdict: REQUEST_CHANGES**`). Case-insensitive; tolerate the word appearing with or without surrounding markdown emphasis.
- A comment-stated verdict is authored by whatever bot/account posted the comment. Treat it exactly like a formal review from that account for the per-reviewer tally and the latest-wins dedup rule above — compare its timestamp against that account's other reviews/comments and keep only the latest.
- Do not infer a verdict from tone or general sentiment (e.g. a comment that merely sounds positive or negative). Only count it when the comment text names an explicit review-verdict word; otherwise it's ordinary comment activity, not a stance.
- If the same bot has posted multiple comments with different stated verdicts (e.g. it re-posts a fresh summary each run), keep only the most recent one by comment `created_at`.

# Diff Acquisition Notes

- PR mode: `gh pr diff <N>` gives the full unified diff; combine with the scoped GraphQL/REST field projections from `pr-cost-control.md` only if per-file/per-line metadata (not diff content) is needed. Do not fetch full file contents unless a hunk's context is insufficient to categorize — then use `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` per `pr-mode-readonly.md`, never the local working tree.
- Local mode: `git diff <merge-base>...HEAD` plus `git diff` for uncommitted changes; state which of the two (or both) were included in the summary.
