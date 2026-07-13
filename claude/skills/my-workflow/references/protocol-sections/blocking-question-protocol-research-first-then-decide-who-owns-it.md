## Blocking-Question Protocol (research first; then decide who owns it)

Every candidate question is one of two kinds, and they are handled differently:

- A **factual question** has a knowable right answer (how the code behaves, what a ticket says, whether a table exists, what a prior decision was). These you must answer yourself — never bounce them to the user.
- A **decision** is a judgment call with no single right answer (which approach, what scope trade-off, what the product should do, whether the spec/plan is right). These belong to the user.

For every candidate, run this in order:

1. **Re-read the artifacts.** The answer is often already in the research doc, spec, plan, ticket, ledger, or earlier in this conversation.
2. **Research the codebase.** Spawn `codebase-locator` / `codebase-analyzer` / `codebase-pattern-finder` to settle how the code actually behaves, what conventions exist, or what's already wired up.
3. **Search Notion, Google Drive + Linear.** Use `notion-search` / `notion-query-data-sources` for design docs, RFCs, and meeting notes; use `Google_Drive__search_files` + `Google_Drive__read_file_content` (and `download_file_content` for non-Docs files) for specs, PRDs, and design docs that live in Drive; fetch linked Linear issues and their comments. Product intent and prior decisions frequently live in one of these — check all three before concluding the answer isn't written down anywhere.
4. **Classify what remains.**
   - **Factual and now resolved** → log it as an assumption in the ledger and proceed. (A reversible, trivial, non-decision detail — e.g., what to name a private helper — may be defaulted the same way; it is not a decision.)
   - **A genuine decision** → it does NOT get auto-defaulted. Prepare it for the user: the options, the pros/cons, your recommendation, and the evidence you gathered. Carry it to the batched stop.

A question reaches the user only if it is a **genuine decision** that steps 1–3 could not convert into a fact. Decisions are never resolved by "a competent engineer could pick something" — that is exactly the judgment the user reserves.

**When you stop**, batch all surviving decisions into one message:
> Reached a decision point at **[stage]**. I researched **[code / Notion / Google Drive / Linear / artifacts]** and resolved the factual questions (**[X, Y]**, logged as assumptions). I need your decision on: **[the decisions]** — options: **[A vs B]**, my recommendation: **[…]** because **[evidence]**.

On the answer, resume from that stage with the decision folded into the ledger. Do not restart from the top.
