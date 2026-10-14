---
name: commit
description: "Commit current changes in logical groups using my ~/.gitmessage template."
when_to_use: "Use when the user asks to commit, save, or check in work, or says a change is ready to land."
effort: xhigh
---

Group the changes into logical commits. Stage only the files that belong
together, and never sweep in unrelated changes I made.

Write each message from the template in `~/.gitmessage`: a subject of 50
characters or fewer, a blank line, then its three headings with their
underlines, each answered in a few lines wrapped at 72:

- Why are these changes introduced?
- Why do the changes satisfy the requirements?
- How do these changes affect existing functionality?

Leave out the template's `#` comment lines. Pass the message with a heredoc,
not an editor.

**Pre-commit hooks are the gate.** Let them run and read their output. A
failed hook means nothing was committed, so don't report success until
`git log -1` shows the new commit.

- If a hook rewrote files (a formatter, an autofixer), review what it changed,
  stage it, and commit again.
- If a hook reports errors (lint, types, tests, secrets), fix the code that
  caused them, then commit again. Fix the cause. Don't silence the check:
  no disable comments, no rule or config edits, no skip variables like
  `SKIP=` or `HUSKY=0`.
- If a fix would change behavior, reach well beyond the staged change, or the
  hook seems wrong, stop and show me the hook output instead of guessing.

Never use `--no-verify`, never amend unless I ask, and never push.
