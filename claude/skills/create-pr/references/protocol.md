# Protocol — create-pr

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Create PR

Create a pull request with a description that does more than restate the diff. The point is to **route the review** — tell the human which lens to apply, which specialty reviews to run, and where to look closely.

## Getting Started

`$ARGUMENTS` is optional. If present, treat it as override notes for the PR body (e.g., "emphasize the migration risk", "frame this as a refactor", "draft").

## Step 1 — Preflight

Verify the branch is ready for a PR:

```bash
git status
git rev-parse --abbrev-ref HEAD
git log --oneline <base>..HEAD
```

Stop and report if:
- Working tree has uncommitted changes
- Branch is the base branch itself (no PR to make)
- No commits ahead of base
- Branch hasn't been pushed (`git rev-parse --abbrev-ref --symbolic-full-name @{u}` fails) — **but see the "Unpushed branch is not a hard stop" gotcha**: a brand-new feature branch on its first PR is the normal case, not misuse. Continue through Steps 2–6 and push as part of Step 7, not as a separate decision.

Detect existing PR for the branch:

```bash
gh pr view --json number,state,body,title,baseRefName,url
```

- Open PR → **update mode** (`gh pr edit ... --body-file`)
- Closed/merged PR → ask before creating a new one
- None → **create mode**

## Step 2 — Gather Context

```bash
git diff <base>...HEAD
git log <base>..HEAD --format="%H%n%s%n%b%n---"
gh pr view --json baseRefName,headRefName    # if updating
```

Detect base branch: prefer the base from an existing PR; otherwise the repo default (`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`).

Parse the linked ticket from:
1. Branch name (e.g. `eng-123-add-foo` → `ENG-123`)
2. Commit messages (look for `ENG-123`, `Closes #N`, Linear URLs, "Related Cards" trailers)
3. Existing PR body (if updating)

### Gather implementation decisions

The PR must carry a concise, auditable record of decisions made while the change was delivered. Find the branch-matched workflow ledger first, using the same branch-first lookup as `my-workflow`:

```bash
branch=$(git branch --show-current)
rg -l -F -e "branch: ${branch}" -e "branch: \"${branch}\"" ~/.claude/thoughts/shared/workflows/ 2>/dev/null
```

Open candidates and compare the `branch:` scalar exactly, including its optional YAML quotes; do not select a similarly named branch.

When a ledger exists, read it completely. Extract decisions and outcomes from
its Need Summary, Scope, Requirements, Decisions, Architecture, Test Strategy,
Implementation Plan, Execution Log, and `## Feedback Round N` sections,
including rejected alternatives and user revisions. For legacy ledgers, also
read `## Provisional Decisions`, the Decisions Checkpoint, and the named plan.
Commit messages are supplementary only when their body records a choice and
rationale.

Include only an evidenced **choice** that affected product behavior, scope, design, compatibility, test contract, rollout, or a plan deviation. For each, preserve its outcome and a short rationale or source reference. Do not turn ordinary task completion, test commands, refactors without a stated trade-off, or an inference from the diff into a decision.

When no decision record is available, state that plainly in the PR body: `No decision record was found for this branch; the diff is not enough to reconstruct why choices were made.` Never claim that no decisions were made merely because no record was found.

## Step 3 — RISC Scoring Analysis

Reason carefully over the diff + commit messages in one pass, using `references/review-categories.md` as the rubric. Produce:

1. **RISC scores** for the change overall (each 1–10):
   - **R**each — how much code does this touch? (1=single function, 10=cross-cutting)
   - **I**rreversibility — how hard to undo? (1=trivial revert, 10=data migration)
   - **S**ubtlety — how easy to misunderstand? (1=obvious, 10=hidden gotcha)
   - **C**onsequence — what breaks if wrong? (1=cosmetic, 10=data loss / security)

   **Verdict thresholds:**
   - Any component ≥9 → **High**
   - Any component ≥7 → **Medium**
   - Otherwise → **Low** (omit Risk Assessment from the body)

2. **Primary lens:** Backend / Frontend / Full-stack / Quality / Security / Architect / PM / Ops — matched to the `/my-review` lens vocabulary.
3. **Secondary lens:** only when both halves of the PR have non-trivial work in different lenses.
4. **Triggered specialty reviews:** any of `/security-review`, `/my-arch-review`, `/perf-review`, eval-coverage call-out — only when the rubric signals actually fire. Each trigger names the specific file(s) that set it off.
5. **Focus areas:** up to 5 `path:line` entries, each with a one-line "why". Prefer places where business-logic intent matters more than code correctness, where the diff is dense, or where boundaries are crossed.
6. **Documentation alignment notes:** only if integration points (APIs, schemas, webhooks, public interfaces, env vars, CLI flags) changed.

Reason from the diff. The rubric is a checklist for the model, not a regex matcher.

## Step 4 — Ground Focus Areas in Tests

For each focus area from Step 3, grep the relevant test root for the function or behavior being claimed:

```bash
# Pick the test root that matches the focus area's language/framework
grep -rn "<function_or_behavior>" <test-root>
```

Any focus area whose claimed behavior has **no matching test** becomes a candidate for the **"Where I'm Uncertain"** section. Cap at 3 entries. Be specific — name the file and the claim that no test verifies, not just "this might be wrong." If every focus area has test coverage, omit the section entirely.

## Step 5 — Compose the Description

Render `references/pr-template.md`, filling each section from Steps 2 through 4.

The template is **two-level by design**: every section is a terse scannable top half (one-phrase bullets, lens names, paths) plus a collapsed `<details>` block carrying the deeper rationale. When composing:

- **Summary top half:** 1–2 sentences of plain language. Frame from a user-visible angle. No file paths, no module names, no implementation detail — those go inside the `What changed` details block.
- **Implementation Decisions:** always render the dedicated collapsed block after Summary. List every evidenced implementation decision from Step 2 as a compact bullet: the choice, outcome, and brief rationale/source. Keep it a decision log, not an implementation tour.
- **Review Guidance top half:** two lines — `Lens: …` and `Triggered specialty reviews: …`. Names only, comma-separated. Rationale goes in the details block.
- **Focus Areas top half:** `path:line` + one-phrase what to verify. The longer "why this matters" goes in the details block.
- **QA Instructions:** user-facing actions only — clicks, URLs, curl calls, MCP tool invocations, reproduction steps. **Never** include `mix test`, `pytest`, `npm test`, lint, or build commands. CI runs those.

The **Review Guidance** section is required on every PR. The **Risk Assessment** block renders only when the RISC verdict is **Medium** or **High**. The **Where I'm Uncertain** section renders only when Step 4 produced entries.

Title:
- Inspired by branch name + commit subjects
- Conventional-commit prefix (`fix:`, `feat:`, `refactor:`, `chore:`, etc.) when it fits
- If `.github/PULL_REQUEST_TEMPLATE.md` or a `pr_*_check` workflow exists, read it and honor any required title pattern (e.g. ticket suffix)
- Otherwise plain title

Save the rendered body to a tempfile (`mktemp`) so `gh` can read it via `--body-file`.

## Step 6 — Show Me

Print the title and full body to the terminal. Wait for explicit direction:

- "create it" / "looks good" / "ship it" → Step 7 (always opens as a draft; see below)
- "edit X" / "rephrase Y" / "drop the Security trigger" / "downgrade to Low" → revise and re-show

**Do not** call `gh pr create` or `gh pr edit` before I approve. Publishing the PR is a visible action and hard to retract cleanly.

## Step 7 — Create or Update

If the branch has no upstream (preflight noted this), push it first as part of the publish action — not as a separate prompt:
```bash
git push -u origin <branch>
```

**Create mode (always opens as a draft):**
```bash
gh pr create --title "<title>" --body-file <tmpfile> --base <base-branch> --draft
```

**Update mode:**
```bash
gh pr edit <number> --body-file <tmpfile> [--title "<title>"]
```

Show me the PR URL after.

## Guidelines

- **Do not fabricate.** Describe only what the diff shows. If you didn't read it, don't claim it. RISC scores must come from the actual change, not pattern-match against the diff size.
- **Implementation decisions are evidence-backed.** Read the branch-matched workflow ledger and linked plan before writing the decisions block. Include every recorded choice that meets Step 2's bar, including confirmed recommendations, user overrides, and implementation/review deviations. A missing record is not evidence that no decision was made; say the record is unavailable rather than reverse-engineering intent from code.
- **Two-level density.** Every section is a terse scannable top half plus a collapsed `<details>` block for the deep context. Top halves are one-phrase bullets or comma-separated names. File paths, internals, and rationale live inside `<details>`. If a reviewer has to expand `<details>` to know what the PR is about, the top half is doing the wrong job.
- **Summary is plain language.** 1–2 sentences. Frame from a user-visible angle. No file paths, no module names, no implementation detail in the Summary itself — those go inside the `What changed` details block.
- **QA Instructions are user-facing.** No `mix test` / `pytest` / `npm test`, no lint, no build commands — CI handles those. QA is click-paths and UI observations, curl / MCP / API calls and expected response shapes, reproduction steps for bug fixes, or trigger + observable side-effect for async work.
- The Review Guidance section is the point of this skill — don't skip it, even on Low-verdict PRs.
- Triggered specialty reviews must be **specific**: name the file(s) and the reason. "Auth might be affected" is not specific.
- Focus areas should be things a human is more likely to catch than a reviewer skill — UX edge cases, business-logic intent, unusual integrations, subtle invariants (idempotency, ordering, timing).
- **Where I'm Uncertain is honest, not exhaustive.** Only call out spots where a test would have verified your claim and didn't exist. Don't pad.
- **Risk Assessment surfaces RISC component scores in the body only when a component is ≥7.** Otherwise the verdict + failure mode + rollback is enough. Don't dump the full RISC table for a Low-verdict PR.
- Documentation alignment: only include when integration points actually changed. Don't pad.
- Don't write findings here that `/my-review` would catch. This skill routes review; it does not perform review.
- Title format: honor repo conventions if detectable, otherwise stay plain. Don't invent a convention.
- Never auto-create. The user approves first, every time.

## References

- `references/pr-template.md` — output template
- `references/review-categories.md` — RISC scoring and lens/trigger rubric

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
