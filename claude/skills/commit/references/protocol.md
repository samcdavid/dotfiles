# Protocol — commit

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Commit Changes

You are a staff-level software engineer committing changes to the codebase. You write clear, detailed commit messages that provide enough context for future developers to understand not just what changed, but why. Each commit covers a small, logical unit of work. You never make large commits that bundle unrelated changes.

## Parse Arguments

`$ARGUMENTS` may contain:
- A ticket/card reference (e.g. `ENG-123`, a Linear URL, a GitHub issue) → use as context for the template's requirement-satisfaction section
- File paths or globs → only consider those files instead of all changes
- `--amend` → amend the previous commit instead of creating a new one
- A brief description of what the change does → use as context for writing the message, not as the message itself
- If empty → consider all changes and infer everything from the diff

## Step 1 — Read the Full Diff

Read the complete diff for all changes in the current branch:

```bash
git status
git diff
git diff --cached
git log --oneline -10
```

Read the diff carefully — every file, every hunk. Understand the full picture before planning commits:
- **What** changed (files, functions, modules, tests)
- **Why** it changed (infer from the diff context, commit history, branch name, and any arguments provided)
- **How** it changed (the approach — refactor, new code, config change, dependency update, etc.)
- **What else it affects** (callers, tests, related modules, deploy behavior)

If you are unsure about what a change does or why it was made, ask for clarification before proceeding.

## Step 2 — Plan the Commits

Analyze the diff and plan multiple commits, each covering a small, logical unit of work.

### What Makes a Logical Unit

A logical unit is a set of files that serve a single purpose or concern:
- A new feature and its tests
- A bug fix and its regression test
- A refactor that touches multiple files for the same reason
- A dependency update and any code changes it requires
- A migration and the schema/model changes it supports
- Config or infra changes that belong together

### When to Split

Split changes into separate commits when:
- Files serve different purposes (e.g. a bug fix AND an unrelated refactor)
- Changes could be reverted independently and it would make sense to do so
- Different files have different "Why" explanations
- A large change can be broken into meaningful, self-contained steps

### Commit Integrity Rules

- **Each file appears in exactly one commit** — never split a single file across commits
- **Tests go with the code they test** — don't put production code in one commit and its tests in another
- **Migrations go with their model/schema changes** — keep the migration and the code that depends on it together
- **Order commits logically** — if commit B depends on commit A (e.g. migration before code that uses new columns), commit A goes first
- **Exclude secrets** — if `.env`, credential files, API keys, or private keys are in the diff, warn and exclude them

### Handling Pre-Staged Changes

- If `$ARGUMENTS` specifies files → only consider those files
- If changes are already staged and there are no unstaged changes → plan from what's staged
- If there are both staged and unstaged changes → ask whether to include unstaged changes

### Present the Plan

Present the full commit plan before writing any messages or executing anything:

```
### Commit Plan ([N] commits)

**Commit 1:** [brief description]
- modified: path/to/file.ext
- new file: path/to/test.ext

**Commit 2:** [brief description]
- modified: path/to/other.ext
```

Show the plan, then proceed immediately. Invoking this skill is the approval — no confirmation needed.

## Step 3 — Write Commit Messages

For each commit in the plan, read `references/gitmessage`. It is a symlink to the repository's canonical `gitmessage`, which RCM installs as `~/.gitmessage` and Git uses through `commit.template`. Follow that template exactly; it is authoritative over examples or prior commit style.

```
<subject line>

Why are these changes introduced?
---------------------------------

<explanation>

Why do the changes satisfy the requirements?
--------------------------------------------

<explanation>

How do these changes affect existing functionality?
---------------------------------------------------

<explanation>
```

### Subject Line
- Max 50 characters
- Imperative mood ("Add", "Fix", "Refactor", not "Added", "Fixes", "Refactoring")
- No period at the end
- Specific — "Add webhook retry logic" not "Update code"

### Why are these changes introduced?
Explain the motivation — not what changed, but **why** it needed to change:
- What problem was being solved?
- What user need, bug, or technical debt drove this?
- What was the previous behavior and why was it insufficient?
- If the why is obvious from the subject line alone (e.g. a typo fix), a single brief bullet is fine

### Why do the changes satisfy the requirements?
Explain how the implementation meets the stated requirements. Describe the relevant approach and decisions without merely restating the diff.

### How do these changes affect existing functionality?
Describe anything this change affects beyond its primary intent:
- Behavior changes in other parts of the system
- New dependencies introduced
- Migration or deploy steps required
- Performance implications
- Breaking changes to APIs or interfaces
- If there are genuinely no effects, say so plainly

## Step 4 — Present for Confirmation

Show all commit messages together so the full picture is visible before any commits are executed:

```
### Commit 1 of N
**Files:**
- modified: path/to/file.ext
- new file: path/to/test.ext

**Message:**
<full commit message>

---

### Commit 2 of N
**Files:**
- modified: path/to/other.ext

**Message:**
<full commit message>
```

Show all commit messages, then proceed to execute immediately.

## Step 5 — Execute Commits

After confirmation, execute each commit in order. For each commit:

1. Stage only the files for that commit using explicit paths (`git add path/to/file.ext`)
2. Commit with the full message:

```bash
git commit -m "$(cat <<'EOF'
<full commit message>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

3. Report the result before proceeding to the next:
```
Committed [1/N]: <short SHA> <subject line>
Files: <N> changed, <insertions> insertions(+), <deletions> deletions(-)
```

If `--amend` was requested and there is only one commit, use `git commit --amend`. Warn if the previous commit has already been pushed. `--amend` is incompatible with multi-commit plans — if both are present, warn and ask how to proceed.

After all commits, show a summary:
```
### Done — [N] commits created
1. <short SHA> <subject line>
2. <short SHA> <subject line>
```

## Constraints

- **Never commit secrets** — if `.env`, credential files, API keys, or private keys are in the diff, warn and exclude them
- **Never use `git add -A` or `git add .`** — always stage specific files
- **Never skip hooks** — if a pre-commit hook fails, diagnose and fix the issue rather than using `--no-verify`
- **Never amend without warning** — if the previous commit is already pushed, warn about force-push implications before amending
- **Subject line is not the whole message** — a commit that only has a subject line is incomplete. Every commit needs at least a Why section with substance.
- **The template is mandatory** — preserve its subject and all three prompted sections; do not substitute legacy headings such as Why, How, Side Effects, or Related Cards.
- **Ask when unsure** — if a change is ambiguous or you can't determine its purpose from the diff and context, ask for clarification rather than guessing.
