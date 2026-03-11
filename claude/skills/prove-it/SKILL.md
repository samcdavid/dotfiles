---
name: prove-it
description: Lightweight fact-check of the current conversation. Separates verified facts from unverified assumptions, cites evidence for each, and flags trust debt. Use when findings feel uncertain or before acting on research.
---

# Prove It

Stop and audit everything you've stated or concluded in this conversation so far.

## Step 1 — Inventory Claims

Review your previous responses. Extract every factual claim, conclusion, and recommendation. Categorize each as:

- **Verified Fact**: You read the actual code, ran a command, or have direct evidence
- **Unverified Assumption**: You inferred, extrapolated, or assumed based on patterns

## Step 2 — Show Evidence

For every verified fact, cite the evidence:
- File path and line number you read
- Command output you observed
- Documentation you referenced

For every unverified assumption, state:
- What you assumed
- Why you assumed it (what pattern or heuristic led you here)
- How to verify it (a specific command, file read, or check)

## Step 3 — Flag Trust Debt

Identify any claims that:
- You stated confidently but haven't actually verified
- Could be stale (code may have changed since you read it)
- Depend on assumptions about behavior you didn't trace

## Step 4 — Verify or Retract

For each piece of trust debt:
1. Verify it now if possible (read the file, run the check)
2. If verified — move it to the verified facts list with evidence
3. If wrong — retract it clearly and state what's actually true
4. If unverifiable right now — flag it explicitly so neither of us forgets

## Output

```
## Verified Facts
- [claim] — evidence: [file:line / command output / doc reference]

## Assumptions (now verified)
- [claim] — was assumed, now confirmed: [evidence]

## Retracted
- [original claim] — actually: [correction]

## Still Unverified
- [claim] — needs: [what would verify this]
```

Be honest. The point is accuracy, not defending previous statements.
