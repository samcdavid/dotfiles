## Step 4 — Ground the Comparison (Research Before Flagging)

Resolve what you can resolve yourself before raising it — always answer your own question first across every source the artifacts lean on:
- **Codebase** (when a plan is involved): `codebase-locator` (confirm all file paths in the plan still exist) and `codebase-analyzer` (verify the plan's "Current State Analysis" matches actual current state). This catches plans written against an older version of the code.
- **Linear / Notion / Google Drive**: when an artifact cites a ticket, RFC, PRD, or design doc as the source of a commitment, fetch it (`notion-search`, `Google_Drive__search_files` + `read_file_content`, linked Linear issues) and check the artifact against it. A contradiction between an artifact and its own cited source is a real finding, not an ambiguity to ask about.

Resolve every discrepancy you can against these sources before listing it. Only a genuine **decision** — which artifact should win, an intentional-vs-accidental deviation that needs the user's judgment — should reach the user.
