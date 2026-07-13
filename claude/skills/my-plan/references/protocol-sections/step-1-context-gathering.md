## Step 1 — Context Gathering

1. Read ALL mentioned files immediately and FULLY (no limit/offset)
2. Research every source before asking the user anything — always answer your own question first. Spawn / search in parallel:
   - **codebase-locator**: Find all files related to the task
   - **codebase-analyzer**: Analyze current implementation of affected components
   - **codebase-pattern-finder**: Find similar implementations to model after
   - **requirements-tracer** (conditional — see triggers below): Map blast radius for intended surfaces, discover related Linear issues, evaluate regression risk on shipped features. Pass `mode: plan`, `scope: wide`, the primary Linear issue ID, and `intended_surfaces` derived from the user's task description.
   - **Linear**: the linked issue, its comments, linked issues, and project, for product intent and prior decisions
   - **Notion**: `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes
   - **Google Drive**: `Google_Drive__search_files` + `read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive
3. Check for existing research/specs in `~/.claude/thoughts/shared/research/` and `/specs/` that's relevant
4. Wait for all sub-agents to complete

Per the **"Plans and tickets are not verified facts"** gotcha: when this step or later phases reference another ticket's work as already shipped, or reason about what a component does based on its interface alone, **read the actual code**. A `[x]` in another plan does not mean the code exists. A function "accepting" a parameter does not mean it enforces coherence. Verify mechanism, not just interface — unverified claims compound.

### When to spawn `requirements-tracer`

Spawn it (in parallel with the other sub-agents) when **either**:

1. **Linear ticket linked** in the task description (Linear URL or issue ID regex match).
2. **User named intended surfaces** in the task description (specific function/module/endpoint/column names — anything concrete enough to grep).

If neither applies (the task is exploratory or the user hasn't named what they'll touch), skip the tracer for this pass and reconsider after Step 2 when intended surfaces are clearer.

In `mode: plan`, the tracer reports test surface presence only — it cannot assess whether tests would catch the regression because the regression form isn't known yet. The git-log heuristic is also skipped (no commits yet).

Present your informed understanding. Ask focused questions — only genuine **decisions** that require HUMAN JUDGMENT (architectural direction, product intent, priorities, irreversible trade-offs). Do not ask questions answerable by reading code, Linear, Notion, or Google Drive — answer those yourself and flag them as assumptions.
