## Step 2 — Metrics Design

For each critical operation, identify metrics to capture:

### Request/Operation Metrics (RED method)
- **Rate**: requests per second, operations per minute
- **Errors**: error count and error rate (percentage)
- **Duration**: latency percentiles (p50, p95, p99)

### Resource Metrics (USE method)
- **Utilization**: CPU, memory, disk, connection pools
- **Saturation**: queue depth, thread pool exhaustion, backpressure
- **Errors**: resource-level failures (connection refused, OOM)

### Business Metrics
- **Success rate for valid input**: The feature should work for good input — if it doesn't, something is broken
- **Throughput**: Are operations completing at the expected volume?
- **Data quality**: Are outputs valid? (schema violations, empty responses, truncated data)

Specify each metric as:
```
Metric: [name]
Type: counter | gauge | histogram | summary
Labels/Tags: [dimensions for filtering]
Source: [where to instrument — file:function or middleware/framework hook]
```
