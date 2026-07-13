## Step 3 — Setup phase

Before any iteration runs:

1. **Define the metric** — what does "better" mean? A single mechanical metric verifiable by a command. Examples:
   - Tests pass + coverage %
   - Benchmark time (ms)
   - Build succeeds + warnings eliminated
   - File/bundle size reduced
   - Lighthouse / accessibility score
   - Lines of code reduced (while tests pass)
   If no metric exists, define one with the user. It MUST be extractable from command output.
2. **Define the verify command** — the exact shell command that produces the metric. Write it down. The agent uses it verbatim.
3. **Define the metric extractor** — regex or one-line instruction for pulling the numeric metric from the verify command's output.
4. **Define scope constraints** — `in_scope_paths` (modifiable) and `read_only_paths` (off-limits).
5. **Define metric direction** — `higher_is_better` or `lower_is_better`.
6. **Create the results log** — see `references/results-logging.md`.
7. **Establish baseline** — run the verify command on the current state. Record as iteration 0.
8. **Present setup to user** — show: goal, metric, verify command, metric extractor, scope, direction, baseline value, iteration limit (or "unlimited"). Get confirmation before starting the loop.
