# Finding Axes — severity, risk, confidence

Every finding a lens reviewer emits carries three independent levels. Lens reviewers **assign** them; the per-finding verifiers (`finding-verifier-high`, `finding-verifier-low`) may **revise** them with cited evidence. Nobody else adjusts them silently.

Read this file if you are a lens reviewer, a finding verifier, or the `my-review` orchestrator routing findings in Step 6.

Axes apply only after a candidate passes `review-contract.md`'s Actionability
Gate. Do not assign levels to an observation, preference, generalized suggestion,
or speculative concern without a present changed-line consequence and a concrete
author-controlled fix, decision, or specific information request.

## The three axes

They answer three different questions. Do not collapse them — a confidently-identified nit and a speculative catastrophe are both "medium" on any single combined score, and that is exactly the distinction the routing depends on.

| Axis | Question it answers | Values |
|---|---|---|
| **Severity** | If this claim is true, how bad is the impact? | `Critical` · `Non-blocking` · `Question` · `Nit` |
| **Risk** | How likely is the failure to actually occur, and how wide is the blast radius when it does? | `High` · `Medium` · `Low` |
| **Confidence** | How sure are you that the claim itself is true? | `High` · `Medium` · `Low` |

### Severity

Use the shared vocabulary from `~/.claude/rules/review-finding-format.md` — that rule is the single source of truth for the `Critical` impact bar, and this file does not restate or relax it. `Critical` denotes the potential impact of likely production breakage, data loss/corruption/exposure, exploitable security or privacy risk, likely runtime break in a cross-service/API/persistence contract, or an omitted must-have acceptance criterion. It is not, by itself, a request-for-changes verdict.

Severity is about impact **conditional on the claim being true**. Do not discount it because you are unsure — that is what `Confidence` is for.

### Risk

Likelihood × blast radius, assuming the claim is true.

- `High` — triggers on a common path, or on an uncommon path whose failure is wide (all tenants, all requests, silent data corruption).
- `Medium` — triggers under a realistic but narrower condition, or the blast radius is contained to one workflow or one tenant.
- `Low` — needs an unlikely combination of conditions, or the effect is cosmetic, recoverable, or trivially retried.

A `Nit` can carry `Low` risk and a `Critical` can carry `High` risk, but they are not locked together: a `Non-blocking` maintainability finding on a hot cross-service path can be `High` risk, and a `Critical`-severity claim guarded by a feature flag defaulting off can be `Low` risk. Findings block on the combination of verified `Critical` severity and `High` risk; otherwise the finding is non-blocking. Separately, `change-set-risk.md` may withhold approval pending human operational-readiness confirmation without turning that handoff into a finding or risk escalation. Say which and why.

### Confidence

Your calibrated belief that the claim is factually correct — read the actual code, not the diff hunk alone, before setting this.

- `High` — you read the relevant code and the defect is visible in it. You could point at the line and defend it.
- `Medium` — the code supports the claim, but it depends on a caller, a schema, a config value, or a library behavior you did not fully verify.
- `Low` — pattern-matched, inferred from naming, or dependent on runtime/production facts you could not reach.

`Low` confidence is a legitimate, useful answer. Do not inflate to `High` for the appearance of rigor, and do not drop a genuinely important finding just because confidence is `Low` — that is what the verifier pass exists to resolve. Never present an unverified claim as verified.

## Routing (orchestrator, Step 6)

Each finding is dispatched **individually** — one verifier per finding, never batched — to exactly one tier:

```
HIGH TIER -> finding-verifier-high   if ANY of:
    severity   == Critical
    risk       == High

LOW TIER  -> finding-verifier-low    otherwise
```

Why this shape: Sol verification is bought only by the impact or blast radius of
a wrong verdict. A `Critical` warrants deep verification because a false
negative can ship a severe defect, and `High` risk earns it on blast radius
alone. Low confidence alone stays in the Terra tier; if it cannot be resolved
there, surface the exact missing evidence as a clarification rather than
spending Sol on a non-Critical, non-High-risk claim.

Compute the tier mechanically from the three levels. Do not hand-pick a tier because a finding "feels" important — if it feels important, that belongs in the levels themselves.

## Escalation from the low tier

`finding-verifier-low` returns `requires clarification` when honest verification
needs depth beyond its brief (cross-service tracing, query plans,
library-version semantics, or a long call chain). It must state the exact fact
and query needed; it must not escalate a non-Critical, non-High-risk finding to
Sol. If the low-tier verifier cites evidence that revises a finding to Critical
or High risk, the orchestrator re-routes that revised finding to the high tier.
