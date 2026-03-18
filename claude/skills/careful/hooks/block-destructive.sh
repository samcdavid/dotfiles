#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qiE '(rm\s+-rf|drop\s+table|drop\s+database|--force|git\s+push\s+.*-f|git\s+reset\s+--hard|kubectl\s+delete|truncate\s+table)'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"/careful is active — destructive command blocked. Disable with a new session if intentional."}}'
  exit 0
fi

exit 0
