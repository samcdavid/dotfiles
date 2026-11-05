# Review draft

The page ends with a review for me to edit and post. You draft it; you never post it. The page posts only when I click its button, and it defaults to a pending review, so nothing is visible to the author until I submit it on GitHub. The review type is mine to choose: keep approve and request-changes language out of the body and comments, and see Suggested review type below.

Fill `<script type="application/json" id="review-draft">`:

```json
{"repo": "owner/repo", "pr": 123, "head": "<full head sha>",
 "suggest": {"event": "COMMENT", "why": "...", "blockers": []}, "body": "...",
 "comments": [{"path": "lib/a.ex", "line": 42, "side": "RIGHT", "note": "T1", "href": "<github link>", "body": "..."}]}
```

Get `head` from `gh api repos/{owner}/{repo}/pulls/{n} --jq .head.sha`.

**Inline comments.** One for each medium or high risk, each `bespoke` plus `new` row, and each rule drift whose code sits in the diff. `line` is the real file line, not a diff position: `RIGHT` for the head side, `LEFT` for deleted code. It must fall inside a diff hunk, or GitHub rejects the whole review (see `my-review/references/publishing.md`, Line Number Rules). Write to the author: what you saw, why it matters, and what you'd suggest. One point per comment, no severity labels. Back it with the source from its risk's verification line, and where a source is silent, ask instead of asserting. Draft nothing from Considered and dismissed, and repeat nothing the PR's conversation already raises. `note` is the risk or row id, exactly as on the page; `href` is the link to that line. The page puts an "Add as inline comment" button on every risk. It uses your draft with the matching `note`, or builds one from the card, so a risk you don't draft is still one click away. A risk whose line isn't in the diff goes into the body instead.

**Body.** Two or three sentences on what the change does and what to look at first, then anything with no line in the diff: risks on code the change doesn't touch, entry-point drift, and open questions.

**Suggested review type.** `suggest.event` is `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`, and `why` is one sentence naming what tipped it, by risk id. The page shows it at the top and labels that option "(suggested)", while the selector stays on Pending: I choose, and nothing is sent until I click. Decide it as Step 7 of `my-review/SKILL.md` does, from the risks on the page:
- `APPROVE`: no blocking risk, and what remains is minor or absent. Security and Architecture must each say what they checked.
- `COMMENT`: worth raising or asking, but nothing must be fixed before merge. Also the choice when you couldn't verify enough to approve, and `why` says what.
- `REQUEST_CHANGES`: a risk card that is a correctness bug, data or security risk, contract break, or missing requirement, at high confidence or confirmed by its verification line. List its ids in `blockers`.

Needs your confirmation items, dismissed risks, anything the product chose not to support, and staging verification count neither way.

**Challenge it before settling**, cheapest first:
1. Write the best case for the opposite type in one sentence, and change the type if the page doesn't rebut it. Ask both ways: too soft (a blocker inside a medium risk) or too harsh (a preference named as a blocker).
2. Dispatch `adversarial-debate` only for `REQUEST_CHANGES`, or for `APPROVE` while a high-confidence risk is on the page. `COMMENT` skips it, because I can overrule one at no cost.
3. Make one call, carrying the type, `why`, the blockers (or the high-confidence risks), and their verification lines. Ask for KEEP, ESCALATE, or DE-ESCALATE with the reason, from its steel-man, severity, and contradiction challenges alone. The risks were already checked against the diff, docs, and Linear, so tell it to skip reference and claim verification. On ESCALATE or DE-ESCALATE, adopt its type and rewrite `why` to name what tipped it.
4. The page's gaps banner enforces the rest: a blocker has high confidence or a confirmed verification and no contradiction; only `REQUEST_CHANGES` lists blockers; `APPROVE`'s `why` names every high-confidence risk; each risk id in `why` is a risk card; and `APPROVE` needs Security and Architecture rows that say what they checked.

For local changes there is no review section, so give the type and its reason in the reply.

Staging verification is QA's job: leave it out.
