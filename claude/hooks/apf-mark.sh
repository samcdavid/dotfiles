#!/usr/bin/env bash
# PreToolUse(Skill) hook — if: Skill(address-pr-feedback)
#
# Sets a session-scoped marker so the Stop gate (address-pr-feedback-checks.sh)
# knows to run format + lint on working-tree changes at each turn-end while the
# skill is active. The marker is keyed by session_id and lives in /tmp, so it is
# scoped to this session and cleared on reboot. There is no "skill end" hook
# event, so the marker is never cleared mid-session — the gate stays armed for
# the rest of the session as a safety net. bash 3.2 safe.

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$sid" ] || exit 0

touch "/tmp/claude-apf-${sid}.flag" 2>/dev/null
exit 0
