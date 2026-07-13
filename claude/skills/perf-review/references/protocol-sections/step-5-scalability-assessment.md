## Step 5 — Scalability Assessment

Think beyond current load:

- If this code path is called 10x, 100x, 1000x more frequently, what breaks first?
- Are there linear-time operations that should be constant-time? (e.g. list scans that should be map lookups)
- Does the design allow horizontal scaling? (no single-process bottlenecks, no local file state)
- Are background jobs configured to handle backpressure? (rate limiting, max concurrency, queue depth)
- Could this change cause cascading failures? (one slow dependency causing timeouts that back up queues)
