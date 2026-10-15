---
name: work
description: "Understand, slice, and build a change in small test-backed steps, keeping a thoughts file so work resumes cleanly after /clear."
effort: xhigh
---

Task: $ARGUMENTS

**Thoughts file:** `~/.thoughts/work/<slug>.md` (slug = issue key or short kebab name).
If $ARGUMENTS names an existing file, or the current branch matches one, resume:
read it and continue from **Next**. Otherwise create it. Update it after every
step. It is the only memory across /clear, so a fresh session must be able to
continue from it alone.

```
# <title>
Goal: one or two sentences
Branch:
## Context    — links to the docs this task relies on, plus task-only facts with file:line
## Slices     — [ ] one behavior each, test-backed
## Decisions  — what was chosen and why
## Thoughts   — open questions, hunches, things to check
## Log        — one line per step: what changed, commit SHA
## Next       — the single next action
```

**Understand.** Start from the `README.md` in the repo's `docs/guides/` and the app's
`docs/guides/<app>/README.md` for conventions, and the product area's folder
under `docs/` for domain context. Read only what's relevant, then the code. If
docs already cover an area, verify them against the code instead of
re-researching. Use Explore subagents only for wide searches. Don't guess.
When a question comes up, answer it yourself from the code first: callers,
tests, similar features, `git log`/`git blame`, and docs. Record the answer
and its `file:line` in Thoughts. Only ask me what the repo can't answer.

**Stay consistent.** Follow the patterns, naming, structure and documented
conventions already in the code and docs. Depart from them only when the
requirements explicitly change that behavior, and then update the docs and
record why in Decisions. Reuse the existing public interface (functions,
modules, components, endpoints) for any flow that already exists; extend it
rather than fork a parallel implementation of the same flow. If reuse truly
won't work, record why in Decisions before building something new.
Comments follow `~/.claude/rules/comment-style.md`: the present-day why, never
the what or the history.

**Save discovery in the repo's docs.** Lasting knowledge about how the system
works, including gotchas and mistakes you hit along the way, belongs in `docs/`,
not the thoughts file or a skill, so the next person or task doesn't regenerate
it. Update the guide that covers the area. Otherwise add
`docs/guides/<app>/<task-named-file>.md` and link it from that app's README.
Designs, decisions and contracts go in the area's folder (for example
`docs/<area>/adr/`). Follow the rules in `docs/guides/` `README.md`. Every claim must be
checked against current code. Commit docs changes like any other slice.

**Slice.** Write 3–8 slices, smallest useful first. Show them once and wait for my OK.

**Loop each slice:** failing test → make it pass → run the narrow tests → commit
(`/commit`) → log it. Pre-commit hook findings are part of the slice: fix them
and commit without asking, unless the fix would change product behavior. Never
silence or skip them. A finding in the slice's own code goes in that commit; a
pre-existing problem the hook flags in a touched file gets its own commit.
Re-slice when you learn something. Stop and ask only for real decisions: product
behavior, irreversible choices, scope changes. Otherwise keep going.

**Done** when every slice is checked and the relevant suite passes. Then suggest `/my-review`.

Never push or open PRs unless I ask.
