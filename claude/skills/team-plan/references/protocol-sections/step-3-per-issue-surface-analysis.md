## Step 3 — Per-Issue Surface Analysis

The goal of this step is **conflict detection only** — not full research, spec, or implementation planning. For each issue, answer two questions: which files will be written to, and which functions or data structures will be modified?

Work through all issues in parallel. For each issue, spawn a **codebase-locator** + **codebase-analyzer** pair scoped tightly to that issue:
- Read the issue description and any linked issues
- Find the files that will need to change (use the broad research from Step 2 as a map)
- Identify the specific functions, schemas, or interfaces that will be added or modified
- Note any shared types, contracts, or module boundaries that other issues might also touch

Record a compact surface profile per issue:
```
ENG-123: writes to [user.ex:changeset/2, user_controller.ex:create/2], touches [User schema]
ENG-456: writes to [user.ex:validate/1, auth.ex:sign_in/2], touches [User schema]
```

Do NOT invoke `/my-research`, `/my-spec`, or `/my-plan` here — that depth is for implementation time, not planning time. If a surface cannot be determined from the ticket and codebase locator, note it as "surface unclear — needs ticket refinement" and flag it for the user.
