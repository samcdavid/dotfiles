## Step 5 — Wave Assignment

Group issues into waves. Hard rules:
- Max `team_size` issues per wave (default 6)
- No two HIGH-conflict issues in the same wave
- Each issue in a wave is one developer's solo work — they own it atomically

Preferred (override when needed):
- Prefer grouping by architectural layer across waves (data-layer changes before API changes before feature work)
- Issues that establish shared interfaces go in the earliest possible wave

For any HIGH-conflict pair that must share a wave, define a **coordination interface**: a shared type, function, or contract both issues agree on before either starts. Add this as a Phase 0 in both plans.

Document the assignment:
```
Wave 1: [ENG-1, ENG-3, ENG-7, ENG-9] — all merge independently before Wave 2 begins
  Coordination note: ENG-1 and ENG-3 both extend UserParams; ENG-1 lands first per slot ordering
Wave 2: ...
```
