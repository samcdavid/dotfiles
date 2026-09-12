#!/bin/bash
#
# claude-daily-spend-statusline.sh
#
# A standalone Claude Code status line with two independent segments: your
# account usage against its limit, and how full the current session's
# context window is.
#
#   36% $121/$333 | 24h [··●··◇··] 7h | 38% ctx (77k/200k)
#
# ── Account usage (left segment) ────────────────────────────────────────
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
# ── Individual Pro/Max plans ─────────────────────────────────────────────
#   Pro/Max accounts don't have a dollar credit limit at all, so the account
#   segment falls back to your current rolling 5-hour session window instead:
#
#     47% session | 5h [···●◇··] 2h
#
#   Same bar mechanics, just scoped to the session window instead of the UTC
#   day: ● is where your session usage actually is, ◇ is where an even pace
#   through the window would put you, and the trailing time is how long
#   until the session resets. This is a real Anthropic-native limit (unlike
#   the dollar figures' Dscout-specific daily ratchet above), so it isn't
#   org-dependent.
#
# ── Context window (right segment) ──────────────────────────────────────
#   38% ctx (77k/200k)  how much of the current conversation's context
#                        window is filled, straight from the same JSON
#                        Claude Code already pipes into this script's stdin
#
#   Present for every account type — Pro, Max, Team, Enterprise — since it's
#   local session data, not something the usage-credits API reports. Color
#   uses Claude Code's own documented thresholds for this figure: green
#   under 70%, yellow 70-89%, red 90%+. Absent for the first few seconds of
#   a session (before the first API response) and briefly after `/compact`,
#   since Claude Code itself reports it as unknown then.
#
# Either segment can be missing independently: on a Pro/Max account with no
# network reachable, you'd see only the context segment; early in a brand
# new session, you'd see only the account segment (or neither, until stdin
# gives Claude Code something to report).
#
# ── Requirements ─────────────────────────────────────────────────────────
#   - macOS or Linux
#   - jq        (brew install jq / apt install jq)
#   - curl      (already on macOS; apt install curl on Linux)
#   - The OAuth token Claude Code logged in with, wherever this OS keeps it:
#       macOS:  Keychain entry "Claude Code-credentials" (created
#               automatically on first login)
#       Linux:  ~/.claude/.credentials.json (created the same way; no
#               Keychain equivalent, so Claude Code just writes the file)
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
#   concatenate its output onto your existing line. Claude Code's JSON only
#   arrives once on stdin, so if your own script also needs it, read stdin
#   yourself and pipe it in rather than letting both scripts race to `cat`
#   the same pipe:
#
#      spend_line=$(printf '%s' "$claude_code_json" | bash ~/.claude/scripts/claude-daily-spend-statusline.sh)
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
SESSION_SECONDS=18000 # 5h rolling window Anthropic calls "session" usage

MUTED_GREEN=$'\033[2;32m'
MUTED_YELLOW=$'\033[2;33m'
MUTED_RED=$'\033[2;31m'
COLOR_RESET=$'\033[2;37m'

command -v jq >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

# Pull the OAuth access token Claude Code already logged in with, from
# wherever this OS keeps it: macOS Keychain, or the plain credentials file
# Claude Code writes on Linux (no Keychain equivalent there).
read_access_token() {
  local blob

  if command -v security >/dev/null 2>&1; then
    blob="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)" || return 1
  else
    local creds="${CLAUDE_CREDENTIALS_FILE:-$HOME/.claude/.credentials.json}"
    [[ -s "$creds" ]] || return 1
    blob="$(cat "$creds")" || return 1
  fi

  [[ -n "$blob" ]] || return 1
  printf '%s' "$blob" | jq -r '.claudeAiOauth.accessToken // empty'
}

# Portable last-modified epoch for a file. BSD stat (macOS) wants `-f
# '%m'`; GNU stat (Linux) wants `-c %Y`. Can't just chain these with `||` on
# exit code: some GNU-alike `stat` builds treat unrecognized `-f '%m'` as a
# different flag entirely (filesystem info, not format) and still dump
# multi-line junk to stdout before failing, which `2>/dev/null` doesn't
# catch — so each attempt's output is validated as a plain integer before
# it's trusted.
file_mtime() {
  local f="$1" out
  out="$(stat -f '%m' "$f" 2>/dev/null)"
  [[ "$out" =~ ^[0-9]+$ ]] && { printf '%s' "$out"; return 0; }
  out="$(stat -c %Y "$f" 2>/dev/null)"
  [[ "$out" =~ ^[0-9]+$ ]] && { printf '%s' "$out"; return 0; }
  printf '0'
}

# Cached globally for 5 minutes so re-rendering the status line on every
# keystroke doesn't hammer the endpoint. Written via a temp file + rename so
# a concurrent reader never sees a half-written file.
fetch_usage() {
  local age token json
  if [[ -s "$CACHE" ]]; then
    age=$(($(date +%s) - $(file_mtime "$CACHE")))
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

# Turns an ISO-8601 timestamp (e.g. "2026-09-13T01:00:00.659887+00:00", the
# shape the usage endpoint's "resets_at" fields use) into a Unix epoch. GNU
# date (Linux) parses that natively; BSD date (macOS) needs the fractional
# seconds stripped and the colon squeezed out of the offset first.
parse_iso8601_epoch() {
  local ts="$1" epoch cleaned
  epoch="$(date -d "$ts" +%s 2>/dev/null)" && { printf '%s' "$epoch"; return 0; }
  cleaned="$(printf '%s' "$ts" | sed -E 's/\.[0-9]+//; s/([+-][0-9]{2}):([0-9]{2})$/\1\2/')"
  epoch="$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$cleaned" +%s 2>/dev/null)" && { printf '%s' "$epoch"; return 0; }
  return 1
}

# Renders the shared 8-slot pacing bar for `pct`-used-so-far against
# `elapsed` seconds into a `period_seconds`-long period, plus the matching
# color and "time left in period" string. Fills the globals BAR/COLOR/LEFT
# rather than returning values, to stay compatible with pre-4.3 bash (no
# namerefs) since macOS still ships bash 3.2.
render_pace() {
  local pct="$1" elapsed="$2" period_seconds="$3" remaining
  local slot_used slot_expected i

  remaining=$((period_seconds - elapsed))
  ((remaining < 0)) && remaining=0

  # Color: red >=90% absolute usage, yellow at/over pace, green under pace.
  # Same thresholds drive both dollar and session modes, so they never
  # disagree in what a given color means.
  if ((pct >= 90)); then
    COLOR="$MUTED_RED"
  elif ((elapsed > 0)) && ((pct * period_seconds >= 100 * elapsed)); then
    COLOR="$MUTED_YELLOW"
  else
    COLOR="$MUTED_GREEN"
  fi

  slot_used=$((pct * SLOTS / 100))
  ((slot_used >= SLOTS)) && slot_used=$((SLOTS - 1))
  ((slot_used < 0)) && slot_used=0
  slot_expected=$((elapsed * SLOTS / period_seconds))
  ((slot_expected >= SLOTS)) && slot_expected=$((SLOTS - 1))
  ((slot_expected < 0)) && slot_expected=0

  BAR=""
  for ((i = 0; i < SLOTS; i++)); do
    if ((i == slot_used && i == slot_expected)); then
      BAR+="◉"
    elif ((i == slot_used)); then
      BAR+="●"
    elif ((i == slot_expected)); then
      BAR+="◇"
    else
      BAR+="·"
    fi
  done

  if ((remaining >= 3600)); then
    LEFT="$((remaining / 3600))h"
  elif ((remaining >= 60)); then
    LEFT="$((remaining / 60))m"
  else
    LEFT="now"
  fi
}

# Whole thousands, rounded to the nearest, with a "k" suffix above 999 —
# e.g. 77400 -> "77k", 850 -> "850". Plain bash arithmetic so it works
# without `numfmt`, which Linux has (coreutils) but macOS doesn't ship.
format_tokens() {
  local n="$1"
  if ((n >= 1000)); then
    printf '%dk' $(((n + 500) / 1000))
  else
    printf '%d' "$n"
  fi
}

# Dollar usage credits only exist on accounts that have them enabled
# (Enterprise/Team). Individual Pro/Max plans don't, so this falls back to
# the rolling 5-hour session utilization the API always reports. Prints
# nothing (not an error) when neither is available — a down network or a
# revoked token shouldn't blank out the context segment too.
build_account_segment() {
  local json mode a b c
  local pct used limit resets_at
  local now_epoch elapsed reset_epoch remaining
  local BAR COLOR LEFT

  json="$(fetch_usage)" || return 0
  [[ -n "$json" ]] || return 0

  read -r mode a b c < <(
    printf '%s' "$json" | jq -r '
      def money(m; e; c):
        (if c == "USD" then "$" else "" end)
        + (((m + (pow(10;e) / 2)) / pow(10;e)) | floor | tostring)
        + (if c == "USD" then "" else " " + c end);

      if (.spend.enabled == true) and (.spend.limit.amount_minor >= 0) then
        "dollar \(.spend.percent) "
        + money(.spend.used.amount_minor; .spend.used.exponent; .spend.used.currency)
        + " "
        + money(.spend.limit.amount_minor; .spend.limit.exponent; .spend.limit.currency)
      elif (.five_hour.utilization != null) and (.five_hour.resets_at != null) then
        "session \(.five_hour.utilization | round) \(.five_hour.resets_at)"
      else
        ""
      end
    ' 2>/dev/null
  )
  [[ -n "${mode:-}" ]] || return 0

  case "$mode" in
    dollar)
      pct="$a" used="$b" limit="$c"
      [[ "$pct" =~ ^[0-9]+$ ]] || return 0

      now_epoch=$(date -u +%s)
      elapsed=$((now_epoch % DAY_SECONDS))
      render_pace "$pct" "$elapsed" "$DAY_SECONDS"

      printf '%s%s%% %s/%s | 24h [%s] %s%s' "$COLOR" "$pct" "$used" "$limit" "$BAR" "$LEFT" "$COLOR_RESET"
      ;;
    session)
      pct="$a" resets_at="$b"
      [[ "$pct" =~ ^[0-9]+$ ]] || return 0
      reset_epoch="$(parse_iso8601_epoch "$resets_at")" || return 0

      now_epoch=$(date -u +%s)
      remaining=$((reset_epoch - now_epoch))
      ((remaining < 0)) && remaining=0
      ((remaining > SESSION_SECONDS)) && remaining=$SESSION_SECONDS
      elapsed=$((SESSION_SECONDS - remaining))
      render_pace "$pct" "$elapsed" "$SESSION_SECONDS"

      printf '%s%s%% session | 5h [%s] %s%s' "$COLOR" "$pct" "$BAR" "$LEFT" "$COLOR_RESET"
      ;;
  esac
}

# Context-window fill, from the JSON Claude Code already sends this script
# on stdin — no network call, so it works the same on every account type.
# Absent for the first few seconds of a session and briefly after
# `/compact`, matching Claude Code's own documented null window for these
# fields; this prints nothing rather than a misleading "0%" then.
build_context_segment() {
  local stdin_json="$1"
  local pct used size color

  [[ -n "$stdin_json" ]] || return 0

  read -r pct used size < <(
    printf '%s' "$stdin_json" | jq -r '
      if (.context_window.used_percentage != null)
         and (.context_window.total_input_tokens != null)
         and (.context_window.context_window_size != null) then
        "\(.context_window.used_percentage | floor) \(.context_window.total_input_tokens) \(.context_window.context_window_size)"
      else
        ""
      end
    ' 2>/dev/null
  )
  [[ -n "${pct:-}" && "$pct" =~ ^[0-9]+$ ]] || return 0

  # Thresholds match Claude Code's own documented convention for this
  # figure (green <70%, yellow 70-89%, red >=90%), not the pacing-bar
  # thresholds used above — there's no "pace" concept for context fill.
  if ((pct >= 90)); then
    color="$MUTED_RED"
  elif ((pct >= 70)); then
    color="$MUTED_YELLOW"
  else
    color="$MUTED_GREEN"
  fi

  printf '%s%s%% ctx (%s/%s)%s' "$color" "$pct" "$(format_tokens "$used")" "$(format_tokens "$size")" "$COLOR_RESET"
}

main() {
  local stdin_json="" account_segment context_segment
  local line="" part parts=()

  # Claude Code always pipes its session JSON in; a bare terminal run (e.g.
  # manual testing without redirecting stdin) would otherwise hang here
  # waiting for EOF, so only read when stdin isn't an interactive tty.
  [[ -t 0 ]] || stdin_json="$(cat)"

  account_segment="$(build_account_segment)"
  context_segment="$(build_context_segment "$stdin_json")"

  [[ -n "$account_segment" ]] && parts+=("$account_segment")
  [[ -n "$context_segment" ]] && parts+=("$context_segment")
  ((${#parts[@]} > 0)) || exit 0

  # Not `IFS=' | '` + "${parts[*]}" — array-join via IFS only ever uses
  # IFS's first character as the separator, which would collapse " | " to
  # a bare space.
  for part in "${parts[@]}"; do
    [[ -n "$line" ]] && line+=" | "
    line+="$part"
  done
  printf '%s\n' "$line"
}

main
