## Step 5 — Execution Plan

### Offline Evals (Pre-Deploy)
- **When to run**: On every prompt/model change, on schedule, or manually
- **Where to run**: CI pipeline, eval platform, or local
- **Blocking vs advisory**: Which scorers block deployment vs just warn?

### Online Evals (Post-Deploy)
- **What to monitor**: Which dimensions can be tracked in production?
- **How to sample**: What percentage of production traffic to eval?
- **Alerting**: What score degradation triggers an alert?

### Iteration Loop
```
Change prompt/model → Run offline evals → Compare to baseline
  → Regression? → Investigate and fix
  → Improvement? → Update baseline, deploy
  → Deploy → Monitor online evals → Feed failures back into dataset
```
