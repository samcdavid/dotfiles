#!/bin/sh
# Resolves today_title and today_iso for skill-start-day Phase 0.
# Never re-derive these by hand (e.g. computing weekday from the date) --
# `date` is the only reliable source for the weekday name.
echo "today_title=$(date +'%A, %B %-d, %Y')"
echo "today_iso=$(date +%Y-%m-%d)"
