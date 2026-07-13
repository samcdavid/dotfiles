## Step 1 — Identify the Pipeline

Establish the CircleCI project and branch context:

1. Get the git remote URL and current branch name
2. Use `mcp__circleci-mcp-server__get_latest_pipeline_status` with project detection (workspaceRoot + gitRemoteURL + branch) to get the current pipeline state
3. Record the pipeline number, workflow IDs, and initial job statuses

If no pipeline is running yet (e.g. just pushed), wait and re-check. The pipeline may take a moment to be created.
