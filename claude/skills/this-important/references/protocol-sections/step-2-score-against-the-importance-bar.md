## Step 2 — Score Against the Importance Bar

For each finding, evaluate against four lenses. Write the score down for each — do not collapse to a gut verdict.

### Impact — what's at stake?

- **Production**: bug, data loss, security vulnerability, outage risk, contract break
- **User**: visible to a user, blocks a workflow, degrades UX measurably
- **System**: degrades performance under realistic load, increases ongoing cost, accumulates debt that compounds
- **Team**: misleads future readers in a way that will cause real bugs, sets a precedent that will be copied harmfully
- **None**: subjective preference, style, taste, "could be cleaner"

### Cost-of-Inaction — what happens if we skip it?

- **Unrecoverable**: data loss, security breach, downstream breakage that can't be rolled back
- **Hard to fix later**: locked into a structure (public API, schema, contract, migration) that will be expensive to change
- **Easy to fix later**: trivially reversible, isolated, no compounding cost
- **Self-correcting**: will surface naturally (tests catch it, monitoring flags it, next reader fixes it)

### Confidence in the Finding Itself

- **Verified**: grounded in actual code, docs, or evidence cited in the finding
- **Plausible**: pattern match, convention, not directly traced
- **Speculative**: based on general knowledge or hypothesis; no project-specific evidence

### Cost-of-Action — what does fixing cost?

- **Cheap**: minutes, isolated edit
- **Moderate**: hours, touches multiple files, requires re-testing
- **Expensive**: days, coordination, migration, or risk of regression
