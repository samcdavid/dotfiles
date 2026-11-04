#!/bin/sh
# Usage: sh open-page.sh <page.html>
#
# The page's "This page has gaps" warning is drawn by its own script, so it only
# exists once a browser runs it. Load the page headless here and print what it
# reports, then open it only when it is clean and only once per run: an agent
# that chains `open` after every edit would otherwise leave a tab per edit.
# CHROME overrides the browser binary used for the check.

page=$1
if [ ! -f "$page" ]; then echo "No such page: $page" >&2; exit 2; fi
case $page in /*) ;; *) page=$(pwd)/$page ;; esac

chrome=
for c in "$CHROME" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" google-chrome google-chrome-stable chromium chromium-browser; do
  [ -n "$c" ] || continue
  if [ -x "$c" ]; then chrome=$c; break; fi
  if found=$(command -v "$c" 2>/dev/null); then chrome=$found; break; fi
done

if [ -z "$chrome" ]; then
  echo "No headless Chrome found, so the page's own checks did not run."
else
  profile=$(mktemp -d) || exit 2
  dom=$("$chrome" --headless=new --disable-gpu --no-sandbox --user-data-dir="$profile" \
    --virtual-time-budget=4000 --dump-dom "file://$(printf '%s' "$page" | sed 's/ /%20/g')" 2>/dev/null)
  rm -rf "$profile"
  if [ -z "$dom" ]; then
    echo "Chrome returned nothing, so the page's own checks did not run."
  else
    gaps=$(printf '%s' "$dom" | tr '\n' ' ' | sed -n 's/.*<div class="check"[^>]*>\(.*\)/\1/p' |
      sed 's/<\/ul>.*//' | sed 's/<[^>]*>/\
/g' | grep -v '^[[:space:]]*$' | sed 1d)
    if [ -n "$gaps" ]; then
      echo "The page is not final. Fix these, then run this again:"
      printf '%s\n' "$gaps" | sed 's/^/  - /'
      exit 1
    fi
  fi
fi

# A marker older than any run could last is left over from an earlier run on the
# same file, so it no longer blocks opening.
marker=$page.opened
if [ -d "$marker" ] && [ -n "$(find "$marker" -maxdepth 0 -mmin +180 2>/dev/null)" ]; then rmdir "$marker"; fi
if mkdir "$marker" 2>/dev/null; then
  case $(uname) in Darwin) open "$page" ;; *) xdg-open "$page" >/dev/null 2>&1 ;; esac
  echo "Clean, and opened once: $page"
else
  echo "Clean. It is already open in a browser from this run. Tell the user to refresh that tab, and do not open it again."
fi
