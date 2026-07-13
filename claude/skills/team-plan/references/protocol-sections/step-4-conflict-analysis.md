## Step 4 — Conflict Analysis

Using the surface profiles from Step 3, identify every file written to by more than one issue.

Build a conflict matrix:

```
         ENG-1   ENG-2   ENG-3   ENG-4
ENG-1      —     HIGH     —      LOW
ENG-2    HIGH     —      MED      —
ENG-3      —     MED      —      NONE
ENG-4    LOW      —      NONE     —
```

Conflict levels:
- **HIGH**: Both issues write to overlapping functions or structures in the same file
- **MED**: Both touch the same file in distinct sections; additive changes
- **LOW**: Both read the same type/interface without modifying it
- **NONE**: No file overlap
