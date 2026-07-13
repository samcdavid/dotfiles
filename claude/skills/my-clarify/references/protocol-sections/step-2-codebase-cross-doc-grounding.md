## Step 2 — Codebase + Cross-Doc Grounding

Before you list ambiguities, **resolve everything you can resolve yourself.** Most candidate "blocking issues" turn out to be answerable from the code, the linked tickets, or an adjacent document — finding that out *before* presenting them to the user is the whole point of this step. Always try to answer your own question first.

Spawn / search in parallel (skip whichever doesn't apply):
- **Codebase** — `codebase-analyzer` (trace the actual behavior of any claim the document makes about existing code) and `codebase-locator` (confirm referenced files, modules, and boundaries exist as described)
- **Linear** — referenced issues, their comments, linked PRs, and projects
- **Notion** — `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes the document leans on
- **Google Drive** — `Google_Drive__search_files` + `read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive
- **Thoughts artifacts** — prior research/specs/plans the source points at, plus the workflow ledger

Flag any claim that doesn't match reality — those are the most dangerous ambiguities because they look precise. But also: every claim that research *confirms* is a candidate question you no longer need to ask the user. Only a genuine **decision** that no source can settle should reach the user.
