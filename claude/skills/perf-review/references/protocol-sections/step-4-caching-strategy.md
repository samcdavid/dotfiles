## Step 4 — Caching Strategy

- Is caching applied where it would have the highest impact? (frequent reads, expensive queries, stable data)
- Is the cache invalidation strategy correct? (stale data is often worse than no cache)
- Are cache keys specific enough to avoid serving wrong data to wrong users?
- Are TTLs appropriate for the data's rate of change?
- Could cache stampedes occur? (many concurrent requests for the same expired key)
- Is there a thundering herd risk on cache invalidation?
