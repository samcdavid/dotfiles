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

Let pre-commit hooks run. If one fails, fix the cause and make a new commit.
Never use `--no-verify`, never amend unless I ask, and never push.
