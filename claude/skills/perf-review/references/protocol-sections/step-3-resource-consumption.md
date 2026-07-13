## Step 3 — Resource Consumption

### Memory
- Are large data sets loaded into memory entirely, or streamed/chunked?
- Do GenServers or processes accumulate state without bounds?
- Are there file uploads or downloads buffered fully in memory?
- Could ETS tables or caches grow without eviction policies?

### Connections
- Are database connection pools sized appropriately for the new load?
- Are external HTTP connections pooled and reused, or opened per request?
- Could connection pool exhaustion occur under load? (all connections checked out, new requests block)
- Are connections returned promptly? (no holding connections during slow external calls)

### CPU
- Are there expensive computations on the request path that could be deferred?
- Are there regex operations or JSON parsing on large inputs without size limits?
- Could any computation be memoized or cached?

### Disk / I/O
- Are log volumes appropriate? (verbose logging in hot paths can fill disks)
- Are temporary files cleaned up?
- Are file operations blocking the request path?
