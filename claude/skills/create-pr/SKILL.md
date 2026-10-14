---
name: create-pr
description: "Create or update the current branch's GitHub PR with a scannable description, risk score, review guidance, and test-grounded focus areas."
effort: xhigh
---

Write a PR description for the current branch, show it to me, then create or update the PR when I say so. `$ARGUMENTS` are optional notes (e.g. "emphasize the migration", "frame as a refactor").

**Preflight.** Stop and tell me if the tree is dirty, the branch is the base branch, or it has no commits ahead of base. An unpushed branch is normal, not a stop. Base = existing PR's base, else the repo default. `gh pr view --json number,state,title,body,baseRefName,url`: open PR → update it; closed/merged → ask before making a new one; none → create.

**Gather.** Read `git diff <base>...HEAD` and the commit log. Find the linked ticket from the branch name, commits, or existing body. Take implementation decisions from the matching `~/.thoughts/work/` file's Decisions section, or commit bodies that record a choice and why. Never infer decisions from the diff; if there's no record, say so.

**Analyze.**
- RISC score (1–10 each): Reach, Irreversibility, Subtlety, Consequence. Any ≥9 → High, any ≥7 → Medium, else Low. Migrations, persisted formats, public API contracts, auth, billing, async retry/ordering, and LLM prompts usually push a score to 7 or higher.
- Primary lens (Backend, Frontend, Full-stack, Quality, Security, Architect, PM, Ops), and a secondary lens only if both halves are substantial.
- Triggered concerns (Security, Architecture, Performance/Migration, Ops, LLM eval), each naming the files that set it off.
- Up to 5 `path:line` focus areas. Grep tests for each; up to 3 untested claims go under "Where I'm Uncertain".

**Compose** using `references/pr-template.md`. Honor any repo title pattern (e.g. a ticket suffix) from `.github/`; otherwise keep the title plain. Describe only what the diff shows.

**Show me** the title and full body. Don't call `gh pr create`/`gh pr edit` until I approve. On approval: push with `git push -u origin <branch>` if there's no upstream, then `gh pr create --draft --title … --body-file <tmp> --base <base>`, or `gh pr edit <n> --body-file <tmp>`. Return the URL.
