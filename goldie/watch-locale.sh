#!/bin/bash
#
# Switches the Apple Watch simulator to a language and region, then reboots it
# so the change takes effect. The watch simulator has no working UI for this:
# a real watch takes its language from the iPhone's Watch app, which crashes in
# the simulator.
#
# Usage:
#   goldie/watch-locale.sh de-DE
#   goldie/watch-locale.sh en-US          # back to English
# WATCH_UDID picks the watch; the default is the Apple Watch Ultra 4 used for
# Duffy's screenshots. If the watch comes back showing the red "phone
# disconnected" icon, run again with REBOOT_PHONE=1 to reboot its paired iPhone too.

set -euo pipefail

LOCALE=${1:-}
if [[ ! "$LOCALE" =~ ^[a-z]{2,3}-[A-Z]{2}$ ]]; then
  echo "usage: $0 <locale>   e.g. de-DE, ja-JP, en-US" >&2
  exit 1
fi

WATCH="${WATCH_UDID:-555803A0-495D-4861-AAB9-F00C74C344BF}"
PAIR=$(xcrun simctl list pairs | grep -B1 "Watch: .*($WATCH)" | head -1 | awk '{print $1}')
PHONE=$(xcrun simctl list pairs | grep -A2 "^$PAIR" | grep -oE 'Phone: .*\(([0-9A-F-]{36})\)' | grep -oE '[0-9A-F-]{36}' || true)

xcrun simctl boot "$WATCH" 2>/dev/null || true
xcrun simctl bootstatus "$WATCH" -b >/dev/null

# AppleLanguages sets the language; AppleLocale sets number, date and unit formats
xcrun simctl spawn "$WATCH" defaults write -g AppleLanguages -array "$LOCALE"
xcrun simctl spawn "$WATCH" defaults write -g AppleLocale -string "${LOCALE/-/_}"

if [ "${REBOOT_PHONE:-0}" = 1 ] && [ -n "$PHONE" ]; then
  echo "Rebooting the paired iPhone ($PHONE)"
  xcrun simctl shutdown "$PHONE" 2>/dev/null || true
  xcrun simctl boot "$PHONE"
  xcrun simctl bootstatus "$PHONE" -b >/dev/null
fi

echo "Rebooting the watch ($WATCH)"
xcrun simctl shutdown "$WATCH"
xcrun simctl boot "$WATCH"
xcrun simctl bootstatus "$WATCH" -b >/dev/null

# Give the watch up to a minute to reconnect to its iPhone
if [ -n "$PAIR" ]; then
  for _ in $(seq 1 30); do
    xcrun simctl list pairs | grep "^$PAIR" | grep -q '(active, connected)' && break
    sleep 2
  done
fi

echo "Watch is now $(xcrun simctl spawn "$WATCH" defaults read -g AppleLanguages | tr -d '\n ()"'), region $(xcrun simctl spawn "$WATCH" defaults read -g AppleLocale)"
