## Step 2 — Research First, Then Reason

**Do not ask the user anything yet.** Most of what you'd ask is answerable from the artifacts already in front of you. Burn that research budget before you spend the user's attention.

Gather in parallel where possible:
- **Linear**: the linked issue, its comments, linked issues, and project, for product intent and prior decisions
- **Codebase** (if the spec touches existing code): spawn `codebase-locator` (relevant modules/boundaries) and `codebase-analyzer` (current behavior, data flow, surrounding constraints) in parallel
- **Notion**: `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes
- **Google Drive**: `Google_Drive__search_files` + `read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive
- **Prior conversation context**: if `/my-spec` was invoked mid-session, re-read what's already been said — don't make the user re-state it
- **Adjacent specs/research**: check `~/.claude/thoughts/shared/research/` and `~/.claude/thoughts/shared/plans/` for related artifacts, plus the issue's workflow ledger

For each candidate question you might ask, try to answer it from research first across all of these sources. Note which are genuinely unanswerable. Only a genuine **decision** — a judgment call, product-intent question, scope trade-off, or sign-off — should survive to the user; everything factual you answer yourself and flag as an assumption.
