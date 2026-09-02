#!/bin/bash
#
# claude-daily-spend-statusline.sh
#
# A standalone Claude Code status line with two segments: your raw spend
# against the credit limit, and how that spend compares to how far the UTC
# day has gotten:
#
#   36% $121/$333 | 24h [··●··◇··] 7h
#
#   36% $121/$333  percent used, and used/limit in whole dollars — straight
#                  from the API, not recomputed
#   ●  where your spend actually is (left = you've used less, right = more)
#   ◇  where the clock says you "should" be if you spent evenly all day
#   ◉  both markers land on the same slot
#   7h how much time is left until the daily limit resets at UTC midnight
#
# If the solid dot (●) is left of the open diamond (◇), you're pacing under
# budget. If it's to the right, you're on pace to run out before the day's
# credits reset at UTC midnight. Color follows the same logic on both
# segments: green = under pace, yellow = at/over pace, red = at or above 90%
# spent.
#
# Why "daily" at all: the Anthropic API has no native daily limit — usage
# credits are metered against a single monthly limit. The "24h" framing here
# is specific to Dscout: a custom daily-ratchet script increments each user's
# monthly limit by one day's worth of spend at every UTC midnight, to
# simulate a daily cap Anthropic Enterprise doesn't otherwise support. The
# API's own percent/used/limit figures are today's slice of that ratcheted
# monthly number; this script just plots them against how far into the UTC
# day the clock is. If your org doesn't run something equivalent, the percent
# is really "percent of the month," not "percent of the day," and this bar
# will be misleading.
#
# ── Requirements ─────────────────────────────────────────────────────────
#   - macOS (uses the Keychain — this script is not written for Linux)
#   - jq        (brew install jq)
#   - curl      (already on macOS)
#   - macOS Keychain entry "Claude Code-credentials" (created automatically
#     the first time you log in to Claude Code) — this is where your OAuth
#     token lives.
#   - A Claude Enterprise/Team account with usage credits enabled. Individual
#     Pro/Max plans don't have a dollar credit limit and this segment will
#     print nothing for you (silently, on purpose).
#
# ── Install: you have NO status line configured yet ────────────────────────
#   1. Save this file somewhere permanent, e.g.:
#        mkdir -p ~/.claude/scripts
#        cp claude-daily-spend-statusline.sh ~/.claude/scripts/
#        chmod +x ~/.claude/scripts/claude-daily-spend-statusline.sh
#
#   2. Add this to ~/.claude/settings.json (create the file if it doesn't
#      exist yet):
#        {
#          "statusLine": {
#            "type": "command",
#            "command": "bash ~/.claude/scripts/claude-daily-spend-statusline.sh"
#          }
#        }
#
#   3. Restart Claude Code (or start a new session). You should see the bar
#      at the bottom of the terminal.
#
# ── Adapt: you ALREADY have a status line script ───────────────────────────
#   Don't replace your command — call this script from within yours and
#   concatenate its output (one line, one string — there's no notion of
#   separate "widgets" in here) onto your existing line, e.g.:
#
#      spend_line=$(bash ~/.claude/scripts/claude-daily-spend-statusline.sh)
#      echo "${your_existing_line} | ${spend_line}"
#
#   Everything below is a single self-contained function pipeline; skim
#   main() if you'd rather copy the logic inline instead of shelling out to
#   this file.
#
# Silent on any failure by design: a status line that errors out or hangs is
# worse than one that's occasionally just missing a segment.

set -uo pipefail

CACHE="${CLAUDE_DAILY_SPEND_CACHE:-$HOME/.claude/cache/claude-daily-spend.json}"
TTL="${CLAUDE_DAILY_SPEND_TTL:-300}" # seconds; matches Claude's own poll cadence
ENDPOINT="${CLAUDE_DAILY_SPEND_ENDPOINT:-https://api.anthropic.com/api/oauth/usage}"
SLOTS=8
DAY_SECONDS=86400

MUTED_GREEN=$'\033[2;32m'
MUTED_YELLOW=$'\033[2;33m'
MUTED_RED=$'\033[2;31m'
COLOR_RESET=$'\033[2;37m'

command -v jq >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

# Pull the OAuth access token Claude Code already logged in with, from the
# macOS Keychain entry Claude Code itself created.
read_access_token() {
  local blob
  blob="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)" || return 1
  [[ -n "$blob" ]] || return 1
  printf '%s' "$blob" | jq -r '.claudeAiOauth.accessToken // empty'
}

# Cached globally for 5 minutes so re-rendering the status line on every
# keystroke doesn't hammer the endpoint. Written via a temp file + rename so
# a concurrent reader never sees a half-written file.
fetch_usage() {
  local age token json
  if [[ -s "$CACHE" ]]; then
    age=$(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0)))
    if ((age < TTL)); then
      cat "$CACHE"
      return 0
    fi
  fi

  token="$(read_access_token)" || return 1
  [[ -n "$token" ]] || return 1

  json="$(curl -sS --fail --location --max-time 20 \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    --url "$ENDPOINT")" || return 1
  [[ -n "$json" ]] || return 1

  mkdir -p "$(dirname "$CACHE")" 2>/dev/null
  printf '%s' "$json" >"$CACHE.$$" && mv -f "$CACHE.$$" "$CACHE"
  printf '%s' "$json"
}

main() {
  local json pct used limit now_epoch elapsed remaining
  local slot_used slot_expected bar color left i

  json="$(fetch_usage)" || exit 0
  [[ -n "$json" ]] || exit 0

  # Usage credits only exist on accounts that have them enabled; everyone
  # else gets empty fields here and we print nothing, on purpose. used/limit
  # are formatted to whole dollars here (rounded, not truncated) so both
  # segments below can just interpolate strings.
  read -r pct used limit < <(
    printf '%s' "$json" | jq -r '
      def money(m; e; c):
        (if c == "USD" then "$" else "" end)
        + (((m + (pow(10;e) / 2)) / pow(10;e)) | floor | tostring)
        + (if c == "USD" then "" else " " + c end);

      if (.spend.enabled == true) and (.spend.limit.amount_minor >= 0) then
        "\(.spend.percent) "
        + money(.spend.used.amount_minor; .spend.used.exponent; .spend.used.currency)
        + " "
        + money(.spend.limit.amount_minor; .spend.limit.exponent; .spend.limit.currency)
      else
        ""
      end
    ' 2>/dev/null
  )
  [[ -n "${pct:-}" && "$pct" =~ ^[0-9]+$ ]] || exit 0

  now_epoch=$(date -u +%s)
  elapsed=$((now_epoch % DAY_SECONDS))
  remaining=$((DAY_SECONDS - elapsed))

  # Color: red >=90% absolute spend, yellow at/over pace, green under pace.
  # Same thresholds drive both segments, so they never disagree in color.
  if ((pct >= 90)); then
    color="$MUTED_RED"
  elif ((elapsed > 0)) && ((pct * DAY_SECONDS >= 100 * elapsed)); then
    color="$MUTED_YELLOW"
  else
    color="$MUTED_GREEN"
  fi

  slot_used=$((pct * SLOTS / 100))
  ((slot_used >= SLOTS)) && slot_used=$((SLOTS - 1))
  ((slot_used < 0)) && slot_used=0
  slot_expected=$((elapsed * SLOTS / DAY_SECONDS))
  ((slot_expected >= SLOTS)) && slot_expected=$((SLOTS - 1))

  bar=""
  for ((i = 0; i < SLOTS; i++)); do
    if ((i == slot_used && i == slot_expected)); then
      bar+="◉"
    elif ((i == slot_used)); then
      bar+="●"
    elif ((i == slot_expected)); then
      bar+="◇"
    else
      bar+="·"
    fi
  done

  if ((remaining >= 3600)); then
    left="$((remaining / 3600))h"
  elif ((remaining >= 60)); then
    left="$((remaining / 60))m"
  else
    left="now"
  fi

  printf '%s%s%% %s/%s | 24h [%s] %s%s\n' "$color" "$pct" "$used" "$limit" "$bar" "$left" "$COLOR_RESET"
}

main
