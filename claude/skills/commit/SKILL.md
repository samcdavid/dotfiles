---
name: commit
description: Stage and commit changes following the project's gitmessage template. Analyzes the diff to write a detailed commit with subject line, Why, How, Side Effects, and Related Cards sections. Supports arguments for partial staging or ticket references.
---

# Commit Changes

Stage and commit the current changes using the project's commit message template (`~/.gitmessage`).

## Parse Arguments

`$ARGUMENTS` may contain:
- A ticket/card reference (e.g. `ENG-123`, a Linear URL, a GitHub issue) → include in Related Cards
- File paths or globs → stage only those files instead of all changes
- `--amend` → amend the previous commit instead of creating a new one
- A brief description of what the change does → use as context for writing the message, not as the message itself
- If empty → stage all changes and infer everything from the diff

## Step 1 — Understand the Changes

Gather context in parallel:

```bash
git status
git diff
git diff --cached
git log --oneline -10
```

Read the diff carefully — both staged and unstaged changes. Understand:
- **What** changed (files, functions, modules, tests)
- **Why** it changed (infer from the diff context, commit history, branch name, and any arguments provided)
- **How** it changed (the approach — refactor, new code, config change, dependency update, etc.)
- **What else it affects** (callers, tests, related modules, deploy behavior)

If the changes are unclear or span multiple unrelated concerns, ask whether they should be split into separate commits before proceeding.

## Step 2 — Stage Changes

- If `$ARGUMENTS` specifies files → stage only those
- If changes are already staged and there are no unstaged changes → use what's staged
- If there are both staged and unstaged changes → ask whether to include unstaged changes or commit only what's staged
- Otherwise → stage all changes, but exclude files that look like they contain secrets (`.env`, credentials, keys) and warn about them

Never use `git add -A` blindly. Prefer adding specific files by name. If staging everything, use `git add` with explicit paths.

## Step 3 — Write the Commit Message

Follow the `~/.gitmessage` template exactly:

```
<subject line>

Why
---

- <reason 1>
- <reason 2>

How
---

- <approach 1>
- <approach 2>

Side Effects
------------

- <side effect 1>

Related Cards
-------------

- [Card Name](url)
```

### Subject Line
- Max 50 characters
- Imperative mood ("Add", "Fix", "Refactor", not "Added", "Fixes", "Refactoring")
- No period at the end
- Specific — "Add webhook retry logic" not "Update code"

### Why
Explain the motivation — not what changed, but **why** it needed to change:
- What problem was being solved?
- What user need, bug, or technical debt drove this?
- What was the previous behavior and why was it insufficient?
- If the why is obvious from the subject line alone (e.g. a typo fix), a single brief bullet is fine

### How
Explain the approach taken — the key decisions and tradeoffs:
- What strategy was chosen and why?
- What alternatives were considered (if non-obvious)?
- What's the high-level structure of the change?
- For multi-file changes, describe how the pieces fit together
- Don't just restate the diff — explain the thinking behind it

### Side Effects
Describe anything this change affects beyond its primary intent:
- Behavior changes in other parts of the system
- New dependencies introduced
- Migration or deploy steps required
- Performance implications
- Breaking changes to APIs or interfaces
- If there are genuinely no side effects, write "- None"

### Related Cards
- If `$ARGUMENTS` included a ticket reference, link it here: `- [ENG-123](url)`
- If the branch name contains a ticket reference, include it
- If a Linear ticket is linked, fetch the title for the card name
- If there are no related cards, write "- None"

## Step 4 — Present for Confirmation

Show the full commit message and the list of files being staged:

```
### Files to commit
- modified: path/to/file.ext
- new file: path/to/other.ext

### Commit message
<full message>
```

Do NOT commit without confirmation. The user may want to adjust the message, split the commit, or change what's staged.

## Step 5 — Commit

After confirmation:

```bash
git commit -m "$(cat <<'EOF'
<full commit message>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

If `--amend` was requested, use `git commit --amend` instead. Warn if the previous commit has already been pushed to a remote.

Report the result:
```
Committed: <short SHA> <subject line>
Files: <N> changed, <insertions> insertions(+), <deletions> deletions(-)
```

## Constraints

- **Never commit secrets** — if `.env`, credential files, API keys, or private keys are in the diff, warn and exclude them
- **Never use `git add -A` or `git add .`** — always stage specific files
- **Never skip hooks** — if a pre-commit hook fails, diagnose and fix the issue rather than using `--no-verify`
- **Never amend without warning** — if the previous commit is already pushed, warn about force-push implications before amending
- **Subject line is not the whole message** — a commit that only has a subject line is incomplete. Every commit needs at least a Why section with substance.
- **Why is not How** — "Refactored the auth module" is How. "Auth module was tightly coupled to the HTTP layer, making it untestable" is Why.
