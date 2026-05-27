# Pushback Patterns

When `address-pr-feedback` is investigating a review comment, this file helps decide whether *pushing back* is the right move and how to frame the response. Patterns are distilled from the same ~2,000-PR mining pass that produced `my-review/references/team-review-patterns.md` — senior Elixir-ecosystem contributors across internal-monorepo work and major OSS libraries (Elixir core, Phoenix, Ash, Oban, Nerves, `req`, `phoenix_test`, `credo`, `ex_doc`).

The skill's Step 2 already says "do not accept feedback blindly, and do not reject it without evidence." This file gives concrete shapes for what well-calibrated pushback looks like in practice.

Use these patterns as templates. Each one names the trigger (the kind of comment that prompts it), the argument style (how the response is constructed), and the typical outcome.

---

## Pushback patterns in approximate "use this most" order

### 1. "Out of scope for this PR" — defer to follow-up

**Trigger:** Reviewer raises a real concern that would expand the PR (adjacent refactor, rename, additional tests on unmodified code, broader cleanup, shared abstraction extraction).

**Argument style:** Acknowledge the issue is real. Name *why* keeping it out preserves clarity (PR atomicity, reviewability, deploy-ability). Explicitly hand off to a follow-up PR with a ticket reference when one exists.

**Typical outcome:** Held the line; reviewer accepts the defer.

**Example phrasings observed:**
- *"Out of scope for this PR though: extracting it would touch the existing two caches… Better to design that against three concrete implementations in a follow-up than to retrofit now."*
- *"I have a follow up pr to fix `X` in the `Y` checker. I'll do the renames there."*
- *"In a subsequent PR, I am going to make the key it picks explicit. So I'm going to skip this for now."*
- *"I take that back. It's dug in too many places (namely `EctoRepo`) and I'm not willing to touch so many places in this PR."*
- *"This could be a separate PR."*
- *"Yeah, this probably needs to be tuned. Let's merge and take care of in a bug bash so we can figure out how we want these to be displayed differently."*

**Use when:** The change would meaningfully grow the diff; the concern is orthogonal to the PR's stated intent; you can credibly commit to the follow-up (or a ticket exists).

**Do NOT use as a generic dismissal** — if the reviewer's concern is *intrinsic* to the PR's stated intent, the answer is to fix it here.

---

### 2. "This is intentional / by design"

**Trigger:** Reviewer questions a value, return type, default, or omission that looks wrong but is actually deliberate.

**Argument style:** One or two sentences confirming intent. Name the invariant or constraint that drives the choice. If the underlying context isn't visible from the diff (operational setup, deployment topology, downstream consumer expectations), explain it briefly.

**Typical outcome:** Held the line.

**Example phrasings observed:**
- *"This is by design. Consumers will come in a later PR."*
- *"No, this is a trick to allow Docker to copy a file if it's available — otherwise it will error (like you encountered) if not found."*
- *"Yep — you said this before. This actually is correct for the RPi5 despite what it looks like."*
- *"I did it on purpose to show the default behavior. But if you think it's better to be explicit, please let me know, I can change that."*
- *"That form is entirely stateless (fully client side), so I wouldn't expect it to work as the server never touches the input."*

**Use when:** The reviewer's question stems from a missing piece of context that, once supplied, would resolve their concern.

**Avoid** when the reviewer is questioning a value judgment rather than a fact — for value judgments, use Pattern 7 (trade-off rationale).

---

### 3. Evidence-backed pushback — verify with code, SQL, shell output

**Trigger:** Reviewer (especially an AI reviewer) claims a bug exists, a pattern is wrong, or a constraint is missing.

**Argument style:** Don't argue from intuition. Verify the claim against the actual source (library code, framework internals, RFC text, the codebase). If the claim is right, concede with the fix SHA. If wrong, post the verification.

**Typical outcome:** Either agreed-and-fixed (with regression test) or held-the-line with linked evidence.

**Example phrasings observed:**
- *"False positive — `validate_inclusion/3` already short-circuits on nil. From `deps/ecto/lib/ecto/changeset.ex:2470` (inside `validate_change/3`): `new = if is_nil(value), do: [], else: validator.(field, value)`. The validator function is never invoked when the change value is nil."*
- *"Good catch — real bug. Fixed in `dd92f7e`. Factored the merge from `AccountResolver.features/2` into `Account.merged_features/2`… Added an integration test asserting a flag enabled via `Flippant.enable/2`."*
- *"There are: 4,849 questions with `null` label; 1,041,821 questions with `null` choices; 0 rows with null banked-resources name."* (responding to a defensive-coalesce question with actual SQL counts)
- *"Per RFC 7578 §4.8: 'The multipart/form-data media type does not support any MIME header fields in parts other than Content-Type, Content-Disposition…'"*
- *"Thanks. Neither works for me: [pasted shell output]. I'm on macOS 15."*

**Use when:** The reviewer's claim is falsifiable with a code read, a query, or a shell run. The most senior reviewers in this sample never argue from authority alone — they cite source.

**Template structure for replies:**
```
[Verdict: Real bug | False positive | Behavior shift but intentional]

[Evidence: file:line, code excerpt, SQL count, RFC quote, or shell session]

[Action: "Fixed in <sha>." + test reference  |  "Skipping —" with persistent reason]
```

---

### 4. Acknowledge-and-fix — quick concession on real bugs

**Trigger:** Reviewer catches a clear bug, an obvious oversight, or a leftover paste-error.

**Argument style:** Brief concession. No defense. Often a thumbs-up emoji or single-line "Done." If self-deprecation feels natural, use it — it's well-calibrated humility, not weakness.

**Typical outcome:** Agreed-and-changed.

**Example phrasings observed:**
- *"Good catch."* (followed by "Fixed 👍")
- *"Done!"* / *"Done."* / *"Fixed up!"*
- *"Right! How'd this get in here."*
- *"Doh. Right you are. I was comparing against the released version, not `main`. 👍 Sorry for the noise!"*
- *"Removed it. I copy pasted and I shouldn't have."*
- *"Bad me."*
- *"Yeah this looks like the AI getting confused. I'll update this to the correct env var."*

**Use when:** The reviewer's finding is unambiguously correct and the fix is small. This is the default and most common pushback-adjacent move; making it small and immediate signals respect for the reviewer's time.

**Avoid:** Over-explaining why the bug happened. The reviewer doesn't need a confession; they need to see the fix lands. Save explanations for cases where the *category* of mistake matters (e.g. "I'll add a lint rule to catch this").

---

### 5. Concession-with-context — "good catch + here's what I was thinking"

**Trigger:** Reviewer surfaces a real improvement, and the original choice has a non-obvious reason worth preserving in the thread.

**Argument style:** Accept the change, then briefly explain the original intent. Helps the next reader understand the decision history without re-deriving it. Pair with the actual fix in the same response.

**Typical outcome:** Agreed-and-changed; commit history gains context.

**Example phrasings observed:**
- *"I can do that. I didn't initially because I was just moving the code from the object to the resolver."*
- *"I can add that explicitly. I didn't initially because it's covered in other tests."*
- *"Sure thing. I had started there, and then came here instead because the 2-tuple is so common I wanted to protect for it in the future, but that is probably YAGNI."*
- *"Good catch. It was originally a `notifiable?` function that I turned into a guard. Fixed 👍."*
- *"Yeah, moving rendering and inserting to a stream will be the best. I was trying to keep the PR small, but I can get to that either here or in a quick follow-up."*

**Use when:** The original choice had a thoughtful reason that gets lost without preserving it. Future readers (or future you) will appreciate the context. Don't manufacture rationales for choices that were arbitrary — "I just didn't think of it" is fine to say.

---

### 6. Cite-existing-pattern defense

**Trigger:** Reviewer suggests deduplication, abstraction, or a different approach where the codebase already has an established pattern doing the thing the same way.

**Argument style:** Name the existing file/function/module that follows the same pattern. Explain that diverging here would create *more* inconsistency, not less. Offer to consolidate later if more instances of the pattern appear.

**Typical outcome:** Held the line; reviewer accepts the precedent.

**Example phrasings observed:**
- *"Existing convention — `EventCache.get_launched_event_intercept_studies/0` uses the exact same shape (joins to arm via `assoc(s, :arm_screener)` without filtering arm status). Skipping this change to stay consistent with the existing intercept-cache pattern."*
- *"Skipping — this pattern is copied verbatim from `consent_versions_live.ex:227-240`, which is the established convention for staff LiveViews."*
- *"The URLCache has the same signature."*
- *"You're correct about it being intended for filesystem paths, but it looks like it always joins with a '/' on Windows: [link to test in elixir-lang/elixir]."*
- *"I was going off of Ecto's [differentiation](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-external-vs-internal-data) between internal and external data."*
- *"No other scopes seem to be alphabetized. Doesn't the order they're defined in determine the order routes are evaluated in to find a match?"*

**Use when:** You can name a concrete second site that uses the same pattern. If you can only cite "this is how I'd do it elsewhere," it's not yet a pattern — use Pattern 7 instead.

**Caveat:** If the existing pattern is itself problematic, the reviewer may be right that this is the moment to break it. Don't use this pattern to cement a known bad practice.

---

### 7. Trade-off rationale — multi-paragraph defense of design

**Trigger:** Reviewer questions a design choice that involved real trade-offs.

**Argument style:** Lay out the alternatives you considered. For each, explain why you didn't pick it. Quantify cost when possible (LOC, file count, call sites). End with an offer to revisit if the reviewer has a specific counter-argument.

**Typical outcome:** Held the line, or compromised on a specific point of the trade-off.

**Example phrasings observed:**
- *"This module is a straight copy and paste of `EnumHelpers`, with the module name changed. My sense based on reading the rest of the codebase was that duplication was preferable to either (a) metaprogramming to generate a KeywordHelpers and MapHelpers module, or (b) making a single, more generic module that accepts the target module as an argument. If I'm mistaken, though, I'm happy to do that refactor."*
- *"I guess I'm puzzled by the criticism about complexity… it's a net +43 lines of production code, rigorously tested, in a leaf module (so it doesn't make anything else in the codebase harder to maintain). The file has had something like 20–25 code changes in its 8 years of life…"*
- *"I was on the fence here, and I'm still not completely sure what's more appropriate. My reasoning was that logging is something you want to do in a running system (dev/staging/prod), while this is being done only in tests. But I don't really have a strong opinion."*
- *"The controller and channel sit on opposite ends of the perf/scale tradeoff. The controller renders one section per HTTP request and uses `apply_for_question/3`. The shared portion is ~10 lines of straight field assignment; extracting a `section_base_payload/1` helper would be a shallow wrapper without removing real complexity."*

**Use when:** The reviewer's suggestion is reasonable but you have specific reasons to prefer the current approach. Take the reviewer seriously — write the response as if persuading them, not defending yourself.

**Length calibration:** 2–4 paragraphs is normal here. Single-line defenses for design choices read as dismissive. But: don't write a wall of text on small points — short paragraphs with clear structure beat long monologues.

---

### 8. Counter-design with full alternative

**Trigger:** Reviewer's suggestion is good in spirit but you see a cleaner execution.

**Argument style:** Drop a code block with the alternative. Frame it as "here's another way" rather than "no, mine is better." Invite the reviewer to pick.

**Typical outcome:** Compromised (alternative usually adopted).

**Example phrasings observed:**
- *"Finch provides additional value with a much simpler API. Furthermore, in our case, we need this behavior only for some short-lived internal servers which are dynamically started in our cluster…"* (followed by code block)
- *"Right, maybe it can even be something like: `if size = multipart.size do Req.Request.put_new_header(req, \"content-length\", Integer.to_string(size))`"*
- *"In a nutshell, the issue is that you are passing the struct as arguments to `defn` function. The fix is rather simple…"* (followed by full multi-file diff)
- *"Hmm.. seems this stopped reporting the selections when I changed this to `encode_to_iodata!`. The spec says it must be an atom or binary, so it must not support iodata."* ("I tried" form)

**Use when:** You can write the alternative. Don't propose a counter-design you couldn't implement yourself in the next 15 minutes — that often masks not-yet-formed objections.

---

### 9. Cite documentation / external source

**Trigger:** Reviewer questions a behavior, edge case, or convention.

**Argument style:** Link the canonical source — library docs, RFC, hexdocs, framework guide, internal design doc. Quote the relevant text inline.

**Typical outcome:** Agreed (your side or theirs) with the source as the arbiter.

**Example phrasings observed:**
- *"As [the docs](https://hexdocs.pm/elixir/...) say: 'The advantage of starting a process under the test supervisor is that it is guaranteed to exit before the next test starts.'"*
- *"I was going off of Ecto's [differentiation](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-external-vs-internal-data) between internal and external data."*
- *"I think it always reads `CLAUDE.md` files. I think the [tricky part](URL) is knowing which `CLAUDE.md` to give priority to."*
- *"Compare with this https://www.australia.gov.au/time-zones-and-daylight-saving"*
- *"The `domain` pattern is a newer pattern, and is still in flux a little. A related design doc lives at [internal URL]."*

**Use when:** There's an authoritative source. Avoid linking to your own blog post or a random Stack Overflow answer; those don't carry the same weight.

---

### 10. "I changed my mind" — mid-thread reversal

**Trigger:** During the back-and-forth, you re-read the code or the reviewer's argument lands and you realize your original position was wrong.

**Argument style:** Just say it. No defensiveness about the prior position. Optionally explain what shifted (re-reading, new information, deeper consideration).

**Typical outcome:** Agreed-and-changed; thread closes cleanly.

**Example phrasings observed:**
- *"I changed my mind. Let's just not validate and keep it simple. If it becomes an issue, it can be addressed then."*
- *"I've changed my mind on this implementation :)"*
- *"In continuing the conversation we had about the on-disk format, I'm leaning against using `:ets.tab2file` due to (1) it saving the timestamp field, (2) on restore, needing to adjust every timestamp field after load, and (3) it not having an easy way to version the on-disk format."*
- *"But yeah… maybe `cd6aa59` is a mistake because I have a feeling it will cause confusion to most people."* (reversing his own concession after re-reading)
- *"Ohh I initially misread/misunderstood your comment. I think this might actually be fine."*

**Use when:** Genuine re-evaluation has happened. Don't manufacture position-changes to seem agreeable — that erodes trust over time.

---

### 11. AI-bot fact-check

**Trigger:** An AI reviewer (CodeRabbit, similar) leaves a finding that sounds plausible.

**Argument style:** Don't accept or reject from the surface. Independently verify by reading the cited code. Reply with `**AI fact check:**` prefix and the actual evidence. If wrong, debunk specifically. If right, treat it like any other reviewer's finding (Pattern 4 or 5).

**Typical outcome:** Held-the-line (when bot was wrong) or agreed-and-fixed (when bot was right).

**Example phrasings observed:**
- *"**AI fact check:** This claim is inaccurate. `build(:sms, status: :sent)` already works via the catch-all clause at `factory.ex:1856`."*
- *"**AI fact check:** Real bug confirmed. `import type { datadogRum as DatadogRumType }` imports the *type* of the `datadogRum` export…"*
- *"I think this is a hallucination. The migration worked and is typed correctly locally."*
- *"Not true — have a look at other validations and the way they work."*
- *"No, this is here to make sure we don't insert a billion jobs."* / *"Nope, very small table."* (terse refusals to bot reviewers)

**Use when:** The PR is in a repo with an active AI reviewer. AI reviewers produce a lot of confidently-wrong findings; treating them as authoritative wastes time. The `**AI fact check:**` prefix is the established convention.

**Caveat:** AI reviewers also catch real bugs. The point is verification before action, not blanket dismissal.

---

### 12. Maintainer-decisive — "I'll take it over"

**Trigger:** As the maintainer or feature owner, a contributor's PR doesn't match the direction you want. Negotiating to align it would be slower than just doing it.

**Argument style:** Direct, no-blame. Explain the alternative direction, close the PR or take it over.

**Typical outcome:** Held-the-line via closure or rework.

**Example phrasings observed:**
- *"I am going to take care of this because I had a very different idea of how to go about this that I liked better."*
- *"Sorry, the other PR was a bit more comprehensive and was the way I wanted."*

**Use when:** You're the maintainer, the contributor's design diverges significantly from your vision, and explaining/iterating would burn more time than redoing it. Be transparent about why — silent closures damage contributor relationships.

**Caveat:** This is a maintainer pattern. As a typical contributor responding to review feedback, this rarely applies. Included here because it's part of the broader landscape of pushback shapes.

---

## When to push back vs. when to accept

A decision tree distilled from the sample:

| Reviewer says | First check | Then |
|---|---|---|
| "This is a bug" | Try to reproduce — does the failing case actually fail? | If yes → Pattern 4 (concede + fix + test). If no → Pattern 3 (post the verification). |
| "Use existing helper X" | Does X exist and do what they think? | If yes → Pattern 4 or 5. If no → Pattern 3 (verify in code, name the actual surface). |
| "This couples A and B too tightly" | Is the coupling actually intentional / load-bearing? | If yes → Pattern 7. If no → Pattern 4 or 8. |
| "Add a test for X" | Is X new behavior in this PR, or pre-existing? | If new in PR → Pattern 4. If pre-existing → Pattern 1 (defer). |
| "This won't scale" | Is the scaling concern likely (>10k rows? hot path?) | If likely → Pattern 7 (acknowledge + plan). If speculative → Pattern 9 (cite actual usage). |
| "Use convention Y" | Does the codebase actually use Y consistently? | If yes → Pattern 4. If inconsistently → Pattern 6. |
| "This naming is wrong" | Does the proposed name actually fit better? | If yes → Pattern 4. If no → Pattern 7. |
| AI bot finding | Verify against actual code | Pattern 11. |
| Reviewer suggests broader cleanup | Adjacent or intrinsic? | Adjacent → Pattern 1. Intrinsic → Pattern 4. |

---

## Anti-patterns observed (don't do these)

- **Single-word refusals without context.** "no" / "nope" works only when responding to a bot and the answer is genuinely binary. Used against humans, it reads as dismissive.
- **Over-explaining concessions.** "Good catch — I'm so sorry, I should have caught this. The reason it happened was… [paragraph of self-flagellation]." Take the fix and move on.
- **Manufactured "I changed my mind" reversals.** Used to avoid argument rather than reflect actual position change — erodes trust over time.
- **Citing precedent for known-bad patterns.** "We do it this way everywhere" doesn't justify continuing if "this way" is the problem.
- **Ignoring AI-bot findings as a category.** Some are wrong, some catch real bugs. Pattern 11 (verify) beats blanket dismissal.

---

## Mining metadata

- Sourced from the same ~2,000-PR mining pass that produced `my-review/references/team-review-patterns.md`
- Date range: 2022-01-01 → 2026-05-27
- ~60+ public OSS repos sampled (Elixir, Phoenix, Ash, Oban, Nerves, ex_doc, phoenix_test, credo, req, finch, mint, and many smaller libraries) plus an internal monorepo
- Patterns are listed in approximate "use this most" order — Pattern 1 (out-of-scope defer) is the single most-common pushback shape observed
- All quoted phrasings are from real PR threads; identifying details have been scrubbed
- Confidence is high for the cross-cutting patterns (each reinforced by 4+ unrelated contributors)
