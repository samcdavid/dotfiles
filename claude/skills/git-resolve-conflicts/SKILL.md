---
model: sonnet
name: git-resolve-conflicts
description: Automatically resolve merge and rebase conflicts using intelligent analysis and editing. Reads both sides of each conflict, merges intent rather than picking a winner, stages resolved files, and continues the operation until it completes or genuinely needs you.
when_to_use: "Use when a merge, rebase, or cherry-pick stops with conflicts, or the user asks to resolve them."
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git log:*), Bash(git rebase:*), Bash(git merge:*), Bash(git cherry-pick:*), Bash(git ls-files:*), Read, Edit, MultiEdit
---

# Resolve Git Conflicts

Drive an in-progress merge, rebase, or cherry-pick to completion, preserving the intent of **both** sides of every conflict. Match the conventions of the surrounding codebase — read it before deciding how to merge.

## Load Rules

Read `~/.claude/rules/loop-detection.md` and `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex. For per-conflict analysis detail, the continue loop, and stop conditions, read `references/protocol.md`.

## Constraints

These boundaries matter more than the flow below — when in doubt, honor these:

- **Never** run `--abort`, `--skip`, or `reset --hard`. They discard work; the user decides that, not you.
- **Never** push, or continue past the end of the operation into other work.
- **Never** pick one side wholesale when both sides carry real intent. Picking a side is a last resort.
- **Never** leave a conflict marker (`<<<<<<<`, `=======`, `>>>>>>>`) in a file you touched.
- **Never** guess at a resolution you can't justify. Genuinely ambiguous — both sides changed the same logic incompatibly — means stop and ask, not fabricate a merge.
- **Never** keep looping without progress. Same commit conflicting the same way twice means stop and report.
- **Do** keep resolved code syntactically valid and consistent with the file's existing style.
- **Do** preserve imports, dependencies, API contracts, and test coverage from both branches.

## Flow

Repeat until the operation finishes or a stop condition fires:

1. Identify the in-progress operation and the commit currently being applied.
2. Resolve every conflicted file: read the whole file, understand what each side intended, merge both where compatible.
3. Stage each resolved file and confirm no markers or unmerged paths remain.
4. Continue the operation non-interactively (`GIT_EDITOR=true git rebase --continue`, or the merge/cherry-pick equivalent).
5. If it stops again with new conflicts, loop. If it finishes, stop.

## Output

Return the operation type, how many commits were replayed, each conflicted file with the resolution decision made, anywhere one side was chosen over the other, and any remaining uncertainty. If you stopped early, name the exact blocking conflict and the command the user should run next.
