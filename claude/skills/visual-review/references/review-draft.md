# Review draft

The page ends with a review for me to edit and post. You draft it; you never post it. The page posts only when I click its button, and it defaults to a pending review, so nothing is visible to the author until I submit it on GitHub. The review type is mine to choose: the page only suggests `my-review`'s verdict.

Fill `<script type="application/json" id="review-draft">`:

```json
{"repo": "owner/repo", "pr": 123, "head": "<full head sha>",
 "suggest": {"event": "COMMENT", "why": "...", "blockers": []}, "body": "...",
 "comments": [{"path": "lib/a.ex", "line": 42, "side": "RIGHT", "note": "T1", "href": "<github link>", "body": "..."}]}
```

Get `head` from `gh api repos/{owner}/{repo}/pulls/{n} --jq .head.sha`.

**Inline comments.** The comments `my-review` drafted, one each: every Blocking Issue and Non-blocking Suggestion with a line in the diff, and every Human Acknowledgement no thread already asks. Write each as `my-review/SKILL.md` Guidelines and `my-review/references/publishing.md` Step 3 say: a severity label, a concrete fix for a blocker, and the AI-agent block for a fix. `line` is the real file line, not a diff position: `RIGHT` for the head side, `LEFT` for deleted code. It must fall inside a diff hunk, or GitHub rejects the whole review (Line Number Rules in `publishing.md`). Back a comment with the source from its card's verification line, and where a source is silent, ask instead of asserting. Draft nothing from Considered and dismissed. `note` is the risk, entry-point row, or confirmation id, exactly as on the page, and every comment needs one; `href` is the link to that line. The page puts an "Add as inline comment" button on every risk. It uses your draft with the matching `note`, or builds one from the card, so a risk you don't draft is still one click away. A finding whose line isn't in the diff goes into the body instead.

**Body.** `my-review`'s Summary in one or two sentences, then what has no line in the diff (risks on code the change doesn't touch, entry-point drift), its Questions, and What's Good. Point to a comment instead of restating it.

**Earlier findings.** `my-review` already drops what the PR raised, and the page must not raise it back. A defect is said once in the whole review, in a comment or in the body, never both, and when a risk, an entry-point row, and a rule drift describe the same one, draft it once, on the risk. You may validate an earlier finding without repeating it: where a finding is dismissed as `already raised`, its verification is `confirmed`, and its thread is still live (the author hasn't answered it, and the code is unchanged at head), add one line to the body that links the thread and says what you checked, such as "Agree with the thread on `DuplicateButton.tsx:12` (link): `Questions.copy/2` does skip tags, so it holds." Add no inline comment for it and don't re-argue its point. Where you can't confirm it, add nothing. The page's gaps banner catches the structural cases: a comment with no `note`, a `note` that is a dismissed finding, two comments with one `note` or on one line, a risk id marked in the body that also has a comment, and a confirmation with no comment when no thread asks it.

**Suggested review type.** `suggest.event` is the verdict `my-review` reached at Step 7, after its adversarial challenge, and `why` is its one sentence naming what tipped it, by risk id. `blockers` lists the ids of its Blocking Issues, and only `REQUEST_CHANGES` has any. Run no challenge of your own: Step 7 already did. The page shows the suggestion at the top and labels that option "(suggested)", while the selector stays on Pending: I choose, and nothing is sent until I click. Human acknowledgements, dismissed findings, anything the product chose not to support, and staging verification count neither way. For local changes there is no review section, so give the type and its reason in the reply.

Staging verification is QA's job: leave it out.
