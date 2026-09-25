---
name: careful
description: Activate guardrails that block destructive commands (rm -rf, DROP TABLE, force-push, kubectl delete). Use when working near production data or critical infrastructure.
disable-model-invocation: false
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_SKILL_DIR}/hooks/block-destructive.sh"
---

# Careful Mode

Activates destructive command blocking for this session.

## What's Blocked

The following patterns in Bash commands will be denied:
- `rm -rf` — recursive force deletion
- `DROP TABLE` / `DROP DATABASE` — database destruction
- `git push -f` / `git push --force` — force push
- `git reset --hard` — hard reset
- `kubectl delete` — Kubernetes resource deletion
- `TRUNCATE TABLE` — table truncation

## Usage

Just invoke `/careful` — no arguments needed. The hook activates immediately and stays active for the session.

To disable, start a new session.
