## Step 1 — Issue Inventory

Fetch all issues in the milestone. Use `list_issues` filtered by milestone; if the list is large, save it and process with `jq`. For each issue, read the full description, comments, and linked issues.

Build a compact inventory:

| ID | Title | Status | Priority | Surfaces Mentioned |
|---|---|---|---|---|

Also read Done issues from the same team — understand what patterns were established and what has already shipped.

Save to `~/.claude/thoughts/shared/plans/NNN_inventory_{milestone_slug}.md`.

**Present the inventory and ask for confirmation before proceeding.** The user may correct priorities or surface details that the ticket descriptions miss.
