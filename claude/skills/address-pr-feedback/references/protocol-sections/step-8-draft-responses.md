## Step 8 — Draft Responses

For every pending comment (fixed or not), draft a response. Every response should show that you investigated — not just acted or dismissed.

### For Confirmed Fixes

```
[Acknowledge the concern.] [Brief note on what you verified.] Fixed in [short SHA].
```

Example: "Good catch — traced the code path and `screener_type` can indeed be nil here when cloning from a template. Fixed in abc1234."

Don't just say "Fixed" — show you understood WHY it needed fixing. If you deviated from the reviewer's exact suggestion, explain your alternative and why.

### For Partially Correct Items

```
[Acknowledge the real concern.] [Explain what you found on investigation.]
[Describe your alternative fix.] Fixed in [short SHA].
```

Example: "You're right that this needs error handling, but `Req.post` returns `{:ok, resp}` / `{:error, exception}` so a case match works better than a try/rescue here. Handled both paths in def456."

### For Questions

```
[Direct answer to the question.] [Evidence or reasoning — what you checked.]
```

Be honest. If the answer is "I didn't consider that" or "good catch, investigating", say so. If you checked and the concern doesn't apply, explain what you checked and why.

### For Deferrals

```
Deferring for this PR — [concrete reason: scope, requires coordination, separate concern].
[Follow-up plan: ticket number, next sprint, or specific next step.]
```

Never defer without a follow-up plan. "I'll handle it later" without specifics is not acceptable. If you can't articulate a plan, it's not a valid deferral — just do it.

### For Push Back

```
[Acknowledge the reviewer's concern.] [Concrete evidence for current approach.]
[Linter rule, doc reference, failing test, or contract constraint.]
[Offer to discuss if the reviewer still disagrees.]
```

Push back must include evidence — a linter rule citation, a failing test, a doc reference, a contract requirement. "I prefer it this way" is not push back; it's a preference, and preferences yield to reviewer feedback.

Example: "Tried consolidating these, but ruff's isort rules (I001) force the aliased import into a separate block — combining them creates a lint violation. Happy to discuss if there's a way around it I'm not seeing."

### Reply Targeting

Each drafted response must be tagged with how it will be posted:

- **Thread reply** (for `review_comment` type): Will use `gh api repos/{owner}/{repo}/pulls/{number}/comments -f body="..." -F in_reply_to={comment_id}`. This replies directly in the inline thread where the reviewer left the comment.
- **Quoted reply** (for `review_body` or `issue_comment` type): Will use `gh api repos/{owner}/{repo}/issues/{number}/comments -f body="..."`. The response body should quote the relevant portion of the original comment using `>` markdown quoting, then provide the response below the quote.

Example quoted reply for a review body comment:

```markdown
> Should we also check for launched _or_ closed?

Checked the code path — `launched?` covers both states because `closed` missions always have a `launched_at` timestamp. The only case where they diverge is draft missions, which are filtered out in the query above (line 42).
```

Present all drafted responses to the user for review before posting, showing the reply mechanism for each:

```
### Responses to Post

1. **Thread reply** to [reviewer]'s comment (ID: 12345) on `file:line`:
   > [quoted original comment]
   [your response]

2. **PR comment** quoting [reviewer]'s review body:
   > [quoted text from review]
   [your response]
```
