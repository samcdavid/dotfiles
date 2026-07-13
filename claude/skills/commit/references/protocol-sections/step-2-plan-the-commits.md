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
