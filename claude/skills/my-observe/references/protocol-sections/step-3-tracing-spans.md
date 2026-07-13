## Step 3 — Tracing & Spans

Identify key spans to instrument:
- Entry point span (HTTP request, job execution, event handler)
- External call spans (database, API, cache, queue)
- Business logic spans (critical decision points, branching logic)

For each span:
```
Span: [name]
Location: [file:function]
Attributes: [key contextual data to attach — IDs, types, sizes]
Events: [notable occurrences within the span — retries, fallbacks, cache misses]
```

Focus on spans that help answer: "Where did time go?" and "Where did it fail?"
