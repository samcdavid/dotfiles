## Step 3 — Tripwire Check

Apply `references/tripwire-signals.md`. If ANY signal fires:

**STOP.** Tell me:
- Which signal(s) fired
- Why this might not be the right lane

Ask:

> "These signals suggest this isn't actually small. Continue anyway, or escalate to the full pipeline?"

Yes → proceed. No → name the recommended starting skill (usually `/my-research` or `/my-spec`) and exit.

Do not pass tripwire without my explicit OK. Note any "continue anyway" decision in the Step 8 summary so it's visible in transcript review.
