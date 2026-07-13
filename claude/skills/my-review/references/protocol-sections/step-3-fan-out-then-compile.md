## Step 3 — Fan out, then compile

You orchestrate in two waves: research first (shared context), then specialized per-lens reviewers (parallel), then you merge everything. The deep reasoning lives in the subagents; the synthesis lives here.

### PR Mode — Hard Constraints, propagated to every subagent

Subagents will silently read on-disk files unless told not to. In PR mode you MUST paste this block verbatim into **every** subagent prompt (research and lens reviewers alike):

```
PR Mode Hard Constraints. The PR diff is the source of truth; the local working tree is NOT (main often lags remote, and the PR branch may not exist locally).
- NEVER run git checkout/switch, gh pr checkout, or git fetch origin pull/N/head:<name> — nothing that changes the working tree or creates a local branch ref.
- NEVER read PR-changed files from disk (Read/cat/grep) and treat the result as the PR's code — that reads main, not the PR.
- NEVER compare the PR against local main as a substitute for the diff.
- Read PR code ONLY via: the supplied diff_text, and `gh api repos/{repo}/contents/{path}?ref={pr_head_sha}` for full file contents at PR HEAD.
```

### Wave 1 — Research subagents (parallel, one message)

Spawn these so the lens reviewers get shared deep context instead of each re-deriving it:

- **codebase-analyzer** — deep-read the changed files AND their callers/consumers; map call chains, data flow, dependencies.
- **codebase-pattern-finder** — find how similar changes were made elsewhere; specifically whether a utility/function/module already does what new code adds (duplication is a common finding).
- **docs-researcher** — for new dependencies, or APIs/framework patterns used in ways you're not 100% sure are correct (version-specific behavior). Don't review library usage without checking the actual docs.
- **requirements-tracer** — spawn only if any `tracer_triggers` flag is true. Pass `mode: review`, `scope: wide`, the primary Linear issue ID (if any), the PR number, and `plan_surfaces` if present (it diffs predicted-vs-actual and only re-runs related-issue discovery if they differ meaningfully).

Collect their outputs into a **compact `research_notes` summary** — the load-bearing facts (call chains, duplication hits, doc gaps), not raw dumps. This is what you hand to the lens reviewers.

### Wave 2 — Lens reviewer subagents (parallel, one message)

For each active lens from Step 2, spawn its reviewer. Send them all in a single message so they run concurrently. Pass each the bundle: `mode`, `pr_head_sha`, `repo`, `diff_text`, `changed_files`, `research_notes`, `author_calibration`, `existing_comments_index`, the PR-mode constraints block, plus any lens-specific extras.

| Active lens(es) | Reviewer agent | Extra input |
|---|---|---|
| Security | `security-reviewer` | — |
| Architecture | `arch-reviewer` | — |
| Performance | `perf-reviewer` | — |
| QA | `quality-reviewer` | — |
| PM | `requirements-reviewer` | `requirements_checklist` |
| Backend, Frontend, Full-stack, Ops, Migration, Dependency | `general-reviewer` | `assigned_lenses` (the subset that fired) |

Spawn a reviewer only for lenses that actually fired in triage. Always include `general-reviewer` if any non-specialized lens is active (it also carries the cross-service-contract checks). Each reviewer reads its source-of-truth skill, applies the checklist, dedupes against `existing_comments_index`, and returns a findings fragment.

### Wave 3 — Compile

Merge the lens reviewers' fragments into one findings set:

1. **De-duplicate across reviewers.** Two lenses often flag the same line (e.g. security + general on the same input handler). Collapse to one finding, keeping the most precise framing and noting both lenses.
2. **Re-check dedupe against `existing_comments_index`** — a reviewer may have missed a thread; drop or `add_to_thread` anything already raised.
3. **Assemble** Critical Findings, Non-blocking Suggestions, Targeted Questions, What's Good, the lens deep-dive subsections each reviewer returned (Security Deep-Dive, Architecture Assessment, Performance Deep-Dive, Quality Deep-Dive, Requirements Traceability), and — if the tracer ran — Related-Issue Regression Risks.
4. **Sanity-check coverage**: every active lens produced a fragment. If a reviewer returned an `## Error` (e.g. missing `requirements_checklist`) or came back empty for a lens that clearly applies, re-dispatch it once with a tightened brief before proceeding. Do not silently drop a lens.

This compiled set is what Steps 4–8 operate on.
