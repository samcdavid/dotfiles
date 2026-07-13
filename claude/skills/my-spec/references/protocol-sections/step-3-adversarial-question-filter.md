## Step 3 — Adversarial Question Filter

Before presenting any question to the user, run it through this filter. The bar is high: every surviving question must clear all four.

1. **Already answered?** Is the answer sitting in the ticket, the code, the linked docs, or earlier in this conversation? If yes — drop the question, state your inferred answer as an assumption.
2. **Inferable with reasonable confidence?** Could a competent TPM make a defensible default call? If yes — make the call, flag it as an assumption to confirm.
3. **Does the answer change scope or direction?** If the spec looks the same either way, the question is decorative — drop it.
4. **Independent of other open questions?** If question B's answer is contingent on question A, ask A alone first.

When in doubt, run a quick adversarial pass: spawn an `adversarial-debate` agent (or do it yourself, fresh-eyed) on your draft question list — "which of these are actually load-bearing vs. thoroughness theater?" Keep only the load-bearing ones.
