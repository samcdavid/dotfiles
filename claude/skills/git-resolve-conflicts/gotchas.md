# Gotchas

- **Complete recoverable rebase blockers yourself.** If unstaged or untracked local changes prevent `git rebase --continue`, classify them before stopping: carry changes that are part of the replay into the appropriate commit, and temporarily preserve unrelated edits (for example with a targeted stash), then continue the rebase and restore those edits. Stop only for a genuinely ambiguous resolution, destructive decision, or unrecoverable Git error—not merely because the worktree needs routine local handling.
