---
name: create-pr
description: Create a PR with a concise description plus targeted review guidance — recommended review lens, triggered specialty reviews, and focus areas for human reviewers. Updates an existing PR body in place if one already exists for the branch.
disable-model-invocation: true
---

# Create PR

Create a pull request with a description that does more than restate the diff. The point is to **route the review** — tell the human which lens to apply, which specialty reviews to run, and where to look closely.

Inspired by the dscout/dscout `git-create-pr` skill but generic and personal.

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
- Branch hasn't been pushed (`git rev-parse --abbrev-ref --symbolic-full-name @{u}` fails)

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

## Step 3 — Sequential-Thinking Analysis

Run a single `mcp__sequential-thinking__sequentialthinking` pass over the diff + commit messages. Use `references/review-categories.md` as the rubric. Produce:

1. **Verdict:** major or minor (criteria in the rubric).
2. **Primary lens:** Backend / Frontend / Full-stack / Quality / Security / Architect / PM / Ops — matched to the `/my-review` persona vocabulary.
3. **Secondary lens:** only when both halves of the PR have non-trivial work in different lenses.
4. **Triggered specialty reviews:** any of `/security-review`, `/my-arch-review`, `/perf-review`, eval-coverage call-out — only when the rubric signals actually fire. Each trigger names the specific file(s) that set it off.
5. **Focus areas:** up to 5 `path:line` entries, each with a one-line "why". Prefer places where business-logic intent matters more than code correctness, where the diff is dense, or where boundaries are crossed.
6. **Documentation alignment notes:** only if integration points (APIs, schemas, webhooks, public interfaces, env vars, CLI flags) changed.

Reason from the diff. The rubric is a checklist for the model, not a regex matcher.

## Step 4 — Compose the Description

Render `references/pr-template.md`, filling each section from Step 3. The **Review Guidance** section is required on every PR. The **Risk Assessment** block is included only for **major** changes.

Title:
- Inspired by branch name + commit subjects
- Conventional-commit prefix (`fix:`, `feat:`, `refactor:`, `chore:`, etc.) when it fits
- If `.github/PULL_REQUEST_TEMPLATE.md` or a `pr_*_check` workflow exists, read it and honor any required title pattern (e.g. ticket suffix)
- Otherwise plain title

Save the rendered body to a tempfile (`mktemp`) so `gh` can read it via `--body-file`.

## Step 5 — Show Me

Print the title and full body to the terminal. Wait for explicit direction:

- "create it" / "looks good" / "ship it" → Step 6
- "edit X" / "rephrase Y" / "drop the Security trigger" / "downgrade to minor" → revise and re-show
- "draft" → Step 6 with `--draft`

**Do not** call `gh pr create` or `gh pr edit` before I approve. Publishing the PR is a visible action and hard to retract cleanly.

## Step 6 — Create or Update

**Create mode:**
```bash
gh pr create --title "<title>" --body-file <tmpfile> --base <base-branch> [--draft]
```

**Update mode:**
```bash
gh pr edit <number> --body-file <tmpfile> [--title "<title>"]
```

Show me the PR URL after.

## Guidelines

- The Review Guidance section is the point of this skill — don't skip it, even on minor PRs.
- Triggered specialty reviews must be **specific**: name the file(s) and the reason. "Auth might be affected" is not specific.
- Focus areas should be things a human is more likely to catch than a reviewer skill — UX edge cases, business-logic intent, unusual integrations, subtle invariants (idempotency, ordering, timing).
- Documentation alignment: only include when integration points actually changed. Don't pad.
- Don't write findings here that `/my-review` would catch. This skill routes review; it does not perform review.
- Title format: honor repo conventions if detectable, otherwise stay plain. Don't invent a convention.
- Never auto-create. The user approves first, every time.

## References

- `references/pr-template.md` — output template
- `references/review-categories.md` — major/minor and lens/trigger rubric

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
