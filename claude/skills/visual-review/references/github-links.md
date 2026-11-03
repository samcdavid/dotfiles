# GitHub links

Used when the review is for a PR. Local changes have no PR to link to.

Build the URLs from the repo (`gh repo view --json nameWithOwner`), the PR number, and the PR's head commit. Compute every path's digest in one pass: `for p in <paths>; do printf '%s  %s\n' "$(printf %s "$p" | shasum -a 256 | cut -d' ' -f1)" "$p"; done` (`sha256sum` on Linux).

**What links.** Every `added`, `modified`, or `removed` node, every risk, every entry-point table row, and every edge. Context nodes in the flow don't link.
- A node, risk, or row links its own `file:line`. Make that text the link, inside its `<code>`: `<a class="gh" href="..." target="_blank" rel="noopener noreferrer">path:line</a>`. The template then makes the whole node, card, or row clickable. A table row's `file:line` is the entry point's own code, one link per row. A node citing several ranges links its first.
- An edge links the line where the connection is made: the call, dispatch, or render in the source node's code, or for a `removed` edge the line this change deleted. Put the URL in the edge's `href` and say what happens there in its `note`. If you can't find the line, leave `href` out and the page warns.

**The line is changed in the PR:** `https://github.com/{owner}/{repo}/pull/{n}/files#diff-{digest}R{line}`
- `digest` is the SHA-256 of the repo-root-relative path.
- `R{line}` is the line on the head side. Use `L{line}` for a deleted line, which exists only on the base side.

**The line isn't changed, or its file isn't in the PR:** `https://github.com/{owner}/{repo}/blob/{head-sha}/{path}#L{start}-L{end}`

Set `data-pr` on `<main>` to the PR number. The page then flags any node, risk, row, or edge that has no link.
