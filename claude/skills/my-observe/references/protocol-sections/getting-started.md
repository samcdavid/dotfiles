## Getting Started

Determine scope:
- If `$ARGUMENTS` references a plan, PR, or file path → analyze those specific changes
- If empty → ask the user what changes or system to design monitoring for

Establish the observability stack:
- Ask what platforms are available (Datadog, Grafana, Prometheus, CloudWatch, Honeycomb, New Relic, etc.)
- Ask about alerting channels (PagerDuty, OpsGenie, Slack, etc.)
- If the user isn't sure, keep recommendations platform-agnostic and let them adapt
