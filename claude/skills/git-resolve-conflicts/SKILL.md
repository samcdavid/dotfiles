---
name: git-resolve-conflicts
description: "Resolve merge, rebase, and cherry-pick conflicts by merging the intent of both sides, staging, and continuing until the operation finishes or genuinely needs you."
when_to_use: "Use when a merge, rebase, or cherry-pick stops with conflicts, or the user asks to resolve them."
effort: xhigh
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git log:*), Bash(git rebase:*), Bash(git merge:*), Bash(git cherry-pick:*), Bash(git ls-files:*), Bash(git stash:*), Read, Edit, MultiEdit
---

Finish the merge, rebase, or cherry-pick in progress, keeping what both sides meant to do.

**Loop** until the operation finishes:

1. Work out which operation is running from `git status` and `.git/{rebase-merge,rebase-apply,MERGE_HEAD,CHERRY_PICK_HEAD}`, and note the current commit. If nothing is in progress, say so and stop.
2. For each conflicted file:
   - Read the whole file, not just the hunk.
   - Work out what each side intended. In a rebase, `ours`/`HEAD` is upstream and `theirs` is my commit, so read the marker labels rather than assuming.
   - Merge both sides where they compose, matching the file's style. Keep imports, contracts, and tests from both.
3. `git add` each resolved file. Then `git diff --check` and `git diff --name-only --diff-filter=U` must both come back clean.
4. Continue without opening an editor: `GIT_EDITOR=true git <op> --continue`.

**Never** run `--abort`, `--skip`, or `reset --hard`, and never push. Never take one side wholesale when both carry real intent. Never leave conflict markers behind.

Don't hand-merge lockfiles or generated files. Tell me which tool command regenerates them.

If unstaged or untracked changes block `--continue`:
- fold the ones that belong to the replay into the right commit;
- set unrelated edits aside with a targeted stash and restore them afterwards.

**Stop and ask** when:
- the two sides contradict, or a critical file (schema, API, migration) can't be justified from the code;
- one side deleted something the other side modified;
- Git wants `--skip`, or reports an error I wouldn't expect;
- the same commit conflicts the same way twice;
- the remaining-commit count stalls;
- more than 20 commits have been replayed.

**Report:**
- the operation and its final state;
- each file and how it was resolved;
- every place one side won, and why;
- anything you're unsure of;
- if you stopped early, the blocker and the next command to run.

Note that tests haven't been run yet.
