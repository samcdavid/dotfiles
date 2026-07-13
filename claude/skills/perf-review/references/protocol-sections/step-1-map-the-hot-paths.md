## Step 1 — Map the Hot Paths

Spawn parallel agents:
- **codebase-locator**: Find all files related to the audit scope
- **codebase-analyzer**: Trace data flow from entry points through processing, storage, and response. Identify every database query, external API call, cache interaction, and background job in the changed code paths.

Identify:
- All database queries (reads and writes) in the changed paths
- All external service calls (HTTP, gRPC, message queues)
- All cache reads/writes and their invalidation triggers
- All background jobs and their scheduling/uniqueness configuration
- All loops or iterations over potentially unbounded data sets
- Request/response lifecycle — what happens on every request vs. what's deferred
