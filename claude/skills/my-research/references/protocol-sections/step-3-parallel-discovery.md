## Step 3 — Parallel Discovery

Research every source before concluding anything is unknown — always answer your own question first. Spawn in parallel where possible:

- **Codebase** — `codebase-locator` (find all relevant files/directories), `codebase-analyzer` (deep-read key implementations), `codebase-pattern-finder` (related patterns and conventions).
- **Linear** — the linked issue, its comments, linked issues, and project, for product intent and prior decisions.
- **Notion** — `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes.
- **Google Drive** — `Google_Drive__search_files` + `read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive.
- **Thoughts artifacts** — adjacent research/specs/plans in `~/.claude/thoughts/shared/` and the issue's workflow ledger.

External context (Linear/Notion/Drive) is the starting point for the question, not a substitute for reading code — per the **"Don't stop at external context"** gotcha, every open question or "verify against code" reference it surfaces must be chased into the codebase, not handed back.

If the research touches **Datadog logs/spans** or **Braintrust project logs**, see `gotchas.md` first — attribute-prefixed queries (`@session_id:...`) for Datadog and a `list_recent_objects` discovery step for Braintrust are non-obvious requirements that cause silent 0-result returns or access errors otherwise.

### Available but situational: `requirements-tracer`

The **requirements-tracer** agent is available for spawning here, but is NOT a default. Spawn it ONLY when the research question is explicitly about **change impact or regression risk** — for example:

- "If I change `function_X`, what shipped features depend on it?"
- "What would break if we deprecated this endpoint?"
- "Which Linear issues touch the same code as ENG-1234?"

Do NOT spawn it for general "how does X work" questions. Research is question-driven, not change-driven — the tracer's blast-radius mapping produces noise when there's no change to evaluate.

When spawning, pass `mode: plan` (no diff exists during research), `scope: tight | medium | wide` based on how broad the user's impact question is, and either a Linear issue ID or an `intended_surfaces` list derived from the question.

Wait for ALL sub-agents to complete before proceeding.
