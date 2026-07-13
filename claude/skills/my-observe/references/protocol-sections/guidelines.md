## Guidelines

- Every alert must have TRIAGE STEPS — an alert without guidance is just noise
- Prefer RATE-based alerts over COUNT-based (rate normalizes for traffic changes)
- Use SUSTAINED conditions (e.g., "above threshold for 5 minutes") not instantaneous spikes
- Include context in alerts — trace IDs, affected resource identifiers, links to relevant dashboards
- Start with fewer, high-signal monitors. More can be added after baseline is established.
- When unsure about the platform, write the logic in plain language and let the user translate to their tool's query syntax
