# Gotchas — my-research

Known failure patterns and lessons learned. Read before starting work with this skill.

### Datadog: Use attribute queries, not free-text search
- **Category:** failure-mode
- **Context:** When searching Datadog logs or spans for a specific identifier (session ID, request ID, trace ID, etc.)
- **Wrong:** Free-text search like `query: "069cd63f-19d3-7e0a-8000-39ff7bdec5ba"` — returns 0 results because Datadog free-text search doesn't match against structured attribute values
- **Right:** Attribute-prefixed search like `query: "@session_id:069cd63f-19d3-7e0a-8000-39ff7bdec5ba"` — searches the indexed attribute directly. If you don't know the attribute name, first search with `service:<name>` and a time window, then inspect the returned log attributes to discover the field name.
- **Why:** Datadog indexes structured attributes separately from log message text. Free-text search only matches the `message` field. IDs stored as structured attributes (session_id, user_id, trace_id, etc.) must be queried with the `@attribute:value` syntax.
- **Source:** Observability investigation where free-text search for a session ID returned nothing, but attribute search found 12+ matching logs immediately.

### Braintrust: List projects before querying logs
- **Category:** failure-mode
- **Context:** When querying Braintrust project logs for traces related to a specific feature or service
- **Wrong:** Guessing the project name/ID (e.g., `"default"`) and passing it to `sql_query` — fails with "Missing read access to project_log" if the name is wrong
- **Right:** Call `list_recent_objects(object_type="project")` first to discover available projects and their IDs, then use the correct project ID in `sql_query`. Paginate with `starting_after` if needed — there may be 30+ projects.
- **Why:** Braintrust project names are user-defined and not predictable. The "default" project used during `init_braintrust()` initialization is just a logger name, not the actual project slug for querying. Project IDs are UUIDs that must be discovered through the API.
- **Source:** Observability investigation where querying with a guessed project name failed, requiring a two-step discovery approach.
