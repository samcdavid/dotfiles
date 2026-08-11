#!/usr/bin/env bash
# Atomically claim a PR for review, so concurrent pr-review-loop sessions
# never review the same PR twice.
#
# Usage: claim-pr.sh <owner> <repo> <number> [--session <id>]
# Output: one JSON object (always exit 0 unless usage/IO fails — read the
#         "claimed" field, do not branch on exit status):
#   {"claimed":true,"reclaimed":false,"stolen_from":null,"holder":"<id>","path":"..."}
#   {"claimed":true,"reclaimed":true,...}          -> this session already held it
#   {"claimed":true,"stolen_from":"<id>",...}       -> prior claim was stale (see TTL)
#   {"claimed":false,"holder":"<id>","claimed_at":"...","age_min":N,"path":"..."}
#
# Ledger: one file per claimed PR under
#   ~/.claude/thoughts/shared/pr-review-claims/<owner>__<repo>__<number>.json
# One file per PR rather than a single shared ledger file on purpose: a shared
# file would need read-modify-write, which has no atomic form without flock
# (absent on macOS). A per-PR file gets real mutual exclusion from O_EXCL —
# the noclobber redirect below either creates the file or fails, with no
# window in between.
#
# Env:
#   PR_REVIEW_SESSION        session id when --session is omitted
#   PR_REVIEW_CLAIM_DIR      override the ledger directory
#   PR_REVIEW_CLAIM_TTL_MIN  minutes before a claim is treated as abandoned
#                            (default 90) — without a TTL, a session that
#                            crashes mid-review would block that PR forever.
set -uo pipefail

usage() {
  echo "usage: claim-pr.sh <owner> <repo> <number> [--session <id>]" >&2
  exit 1
}

[ $# -ge 3 ] || usage
owner="$1"
repo="$2"
number="$3"
shift 3

session="${PR_REVIEW_SESSION:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --session)
      shift
      [ $# -gt 0 ] || usage
      session="$1"
      ;;
    *) usage ;;
  esac
  shift
done
[ -n "$session" ] || session="unknown-$$"

case "$number" in
  '' | *[!0-9]*) usage ;;
esac

dir="${PR_REVIEW_CLAIM_DIR:-$HOME/.claude/thoughts/shared/pr-review-claims}"
mkdir -p "$dir" || exit 1
file="$dir/${owner}__${repo}__${number}.json"
tmp="${file}.tmp.$$"
trap 'rm -f "$tmp"' EXIT
ttl_min="${PR_REVIEW_CLAIM_TTL_MIN:-90}"
now=$(date -u +%s)

payload() {
  jq -nc \
    --arg owner "$owner" \
    --arg repo "$repo" \
    --argjson number "$number" \
    --arg session "$session" \
    --arg host "$(hostname)" \
    --argjson pid "$$" \
    --arg claimed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson claimed_at_epoch "$now" \
    '{owner: $owner, repo: $repo, number: $number, session: $session,
      host: $host, pid: $pid, claimed_at: $claimed_at,
      claimed_at_epoch: $claimed_at_epoch}'
}

# Atomic create-or-fail. Returns 0 only if this process created the file.
#
# Write to a temp file first, then hard-link it into place: `ln` fails if the
# target exists, so it is exclusive the same way an O_EXCL create is, but the
# file only becomes visible under its real name once the content is complete.
# A plain `> "$file"` redirect under noclobber is exclusive on *creation* yet
# leaves a window where another session can open the file before the payload
# is flushed, read empty JSON, conclude the claim is ancient, and steal a live
# claim. Observed in a 3-session contention test, so this is not theoretical.
write_exclusive() {
  local rc=0
  payload > "$tmp" || return 1
  ln "$tmp" "$file" 2>/dev/null || rc=1
  rm -f "$tmp"
  return $rc
}

# Overwrite an existing claim we already own, atomically (see write_exclusive
# for why the content must never be visible half-written).
write_replace() {
  payload > "$tmp" || return 1
  mv -f "$tmp" "$file"
}

field() {
  jq -r "$1" "$file" 2>/dev/null || echo "$2"
}

# Seconds since epoch that the claim was taken. Prefers the recorded value and
# falls back to the file's mtime, so a file whose JSON cannot be parsed ages
# out normally instead of reading as epoch 0 — i.e. instantly stealable.
claim_epoch() {
  local recorded
  recorded=$(field '.claimed_at_epoch // empty' '')
  case "$recorded" in
    '' | *[!0-9]*) ;;
    *) echo "$recorded"; return ;;
  esac
  stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo "$now"
}

emit_claimed() {
  jq -nc --arg holder "$session" --arg path "$file" \
    --argjson reclaimed "$1" --arg stolen_from "$2" \
    '{claimed: true, reclaimed: $reclaimed,
      stolen_from: (if $stolen_from == "" then null else $stolen_from end),
      holder: $holder, path: $path}'
}

if write_exclusive; then
  emit_claimed false ""
  exit 0
fi

# The file already exists: someone holds this PR, or a dead session left it.
holder=$(field '.session // "unknown"' unknown)
claimed_at=$(field '.claimed_at // "unknown"' unknown)
at_epoch=$(claim_epoch)
age_min=$(( (now - at_epoch) / 60 ))

if [ "$holder" = "$session" ]; then
  # Our own claim from earlier in this run: refresh it and carry on. Makes a
  # retry after a transient failure idempotent instead of self-blocking.
  write_replace
  emit_claimed true ""
  exit 0
fi

if [ "$age_min" -ge "$ttl_min" ]; then
  # Abandoned claim: the holder is gone and the TTL has passed. Steal it, then
  # re-read to confirm we won — unlink+create is not itself atomic, so two
  # sessions can both reach here and the loser must yield.
  rm -f "$file"
  write_exclusive || true
  winner=$(field '.session // "unknown"' unknown)
  if [ "$winner" = "$session" ]; then
    emit_claimed false "$holder"
  else
    jq -nc --arg holder "$winner" --arg path "$file" \
      '{claimed: false, holder: $holder, claimed_at: null, age_min: 0, path: $path}'
  fi
  exit 0
fi

jq -nc --arg holder "$holder" --arg claimed_at "$claimed_at" \
  --argjson age_min "$age_min" --arg path "$file" \
  '{claimed: false, holder: $holder, claimed_at: $claimed_at,
    age_min: $age_min, path: $path}'
