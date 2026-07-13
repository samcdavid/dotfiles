## Step 1 — Map the Attack Surface

Spawn parallel agents:
- **codebase-locator**: Find all files related to the audit scope
- **codebase-analyzer**: Trace data flow from entry points (user input, API requests, webhooks, queue messages) through processing to storage and output

Identify:
- All entry points where external data enters the system
- All exits where data leaves (responses, logs, emails, third-party APIs)
- All trust boundaries (auth checks, permission gates, service boundaries)
- All data stores touched (databases, caches, file systems, queues)
