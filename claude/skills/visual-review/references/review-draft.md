# Review draft

The page ends with a review for me to edit and post. You draft it; you never post it. The page posts only when I click its button, and it defaults to a pending review, so nothing is visible to the author until I submit it on GitHub. Leave the review type to me: don't write approve or request-changes language.

Fill `<script type="application/json" id="review-draft">`:

```json
{"repo": "owner/repo", "pr": 123, "head": "<full head sha>", "body": "...",
 "comments": [{"path": "lib/a.ex", "line": 42, "side": "RIGHT", "note": "T1", "href": "<github link>", "body": "..."}]}
```

Get `head` from `gh api repos/{owner}/{repo}/pulls/{n} --jq .head.sha`.

**Inline comments.** One for each medium or high risk, each `bespoke` plus `new` row, and each rule drift whose code sits in the diff. `line` is the real file line, not a diff position: `RIGHT` for the head side, `LEFT` for deleted code. It must fall inside a diff hunk, or GitHub rejects the whole review (see `my-review/references/publishing.md`, Line Number Rules). Write to the author: what you saw, why it matters, and what you'd suggest. One point per comment, no severity labels. `note` is the risk or row id; `href` is the link to that line.

**Body.** Two or three sentences on what the change does and what to look at first, then anything with no line in the diff: risks on code the change doesn't touch, entry-point drift, and open questions.

Staging verification is QA's job: leave it out.
