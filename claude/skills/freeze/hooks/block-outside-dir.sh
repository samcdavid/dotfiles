#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$SCRIPT_DIR/freeze-config.json"

if [ ! -f "$CONFIG" ]; then
  exit 0  # No config = no restriction
fi

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
ALLOWED_DIR=$(jq -r '.allowed_dir // empty' "$CONFIG")

if [ -z "$ALLOWED_DIR" ] || [ -z "$FILE" ]; then
  exit 0
fi

# Check if file is within allowed directory
case "$FILE" in
  "$ALLOWED_DIR"*) exit 0 ;;
  *)
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"/freeze is active — edits restricted to '"$ALLOWED_DIR"'. This file is outside the frozen zone."}}'
    exit 0
    ;;
esac
