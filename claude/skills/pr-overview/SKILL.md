---
name: pr-overview
description: "Give a brief, categorized overview of a PR or local diff, flagging requirement/behavior-relevant changes, and for a PR summarize existing review activity."
when_to_use: "Use when the user wants a quick orientation on a PR (number/URL) or the current local diff before reading it in full, rather than a full review or verdict."
effort: xhigh
disallowed-tools: Edit, Write, NotebookEdit
---

Give me a short "what changed and what to look at" summary of $ARGUMENTS. This is not a review: no verdict, severity, or approve/block language.

**Target.** For a PR, read the diff and files at the PR head with `gh` (`gh pr diff`, `gh api .../contents/{path}?ref={sha}`). Never check it out, and never treat the local working tree as PR contents. Without a PR, use `git diff` against the merge-base with the default branch, including uncommitted changes. If there's nothing to summarize, say so and stop.

**Categories.** Scan the diff once and bucket only added or changed lines. Use `references/categories.md` for detection hints. Leave out empty categories.

1. Product requirement changes
2. Edited existing test cases (not newly added tests)
3. New database migrations, or ORM changes missing one
4. Function/method signature changes
5. Public interface changes
6. Branching-condition changes
7. Feature flag use
8. Comment quality
9. Monkey patching
10. Linter suppressions

**Review activity (PR only).** Report each reviewer's latest stance (latest review wins), the count of unresolved non-outdated threads, and a factual lean such as "2 approvals, 1 unresolved thread". Count a verdict word stated in a bot's comment text the same as a formal review. Say plainly if there's no activity yet.

**Prepared comments.** Draft author-directed comments, but never post them and never put them to me as questions. Use the formats in `references/categories.md`. In a PR they're inline comments; locally they're a "Pending before PR or staging" checklist. Skip anything an existing thread already raises.

**Output.**
1. One or two sentences on what the change does.
2. Each non-empty category as `file:line` plus a one-line plain description.
3. Review activity, then the prepared comments.
4. A one-line size gauge: files changed and +/- lines.

If I ask for a verdict, point me to `/my-review`.
