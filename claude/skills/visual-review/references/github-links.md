# GitHub links

Used when the review is for a PR. Local changes have no PR to link to.

Build the URLs from the repo (`gh repo view --json nameWithOwner`), the PR number, and the PR's head commit.

**What links.** Every `added`, `modified`, or `removed` node, every risk, and every entry-point table row. Context nodes in the flow don't link. Make the `file:line` itself the link, inside its `<code>`: `<a class="gh" href="..." target="_blank" rel="noopener noreferrer">path:line</a>`. The template then makes the whole node, card, or row clickable. A table row's `file:line` is the entry point's own code, one link per row. A node citing several ranges links its first.

**File is in the PR's diff:** `https://github.com/{owner}/{repo}/pull/{n}/files#diff-{digest}R{line}`
- `digest` is the SHA-256 of the repo-root-relative path: `printf %s '<path>' | shasum -a 256` (`sha256sum` on Linux).
- `R{line}` is the first changed line on the head side. Use `L{line}` for a `removed` node, whose lines exist only on the base side. Don't anchor to unchanged context.

**File isn't in the PR** (a risk or entry point in untouched code): `https://github.com/{owner}/{repo}/blob/{head-sha}/{path}#L{start}-L{end}`

Set `data-pr` on `<main>` to the PR number. The page then flags any node, risk, or row that has no link.
