#!/bin/bash
#
# App Store screenshots for the iPhone Duo, which goldie has no device for.
# Replays the same argent flows goldie uses (../.argent/flows) on an iPhone Duo
# simulator in three modes, in every locale, and writes plain screenshots to
#   goldie/out/duo/<mode>/<locale>/NN-<scene>.png
# The modes:
#   unfolded           inner panel, landscape UI   2853x2007
#   unfolded-portrait  inner panel, portrait UI    2007x2853
#   folded             cover panel, portrait UI    1398x2034
#
# Needs the Release simulator build (see goldie.config.ts) and goldie installed
# (for its bundled argent). Usage:
#   goldie/capture-duo.sh                 # every locale
#   goldie/capture-duo.sh de-DE ja-JP     # just these
# DUO_MODES picks the modes (default: all three), e.g. DUO_MODES=unfolded-portrait.
# DUO_UDID picks the simulator; the default is the first available iPhone Duo.

set -uo pipefail
cd "$(dirname "$0")/.."

ARGENT="$(dirname "$(readlink -f "$(command -v goldie)")")/../node_modules/.bin/argent"
APP="$HOME/Library/Developer/Xcode/DerivedData/Duffy-ejlmvhqurzqnrebmetnfviqlqurq/Build/Products/Release-iphonesimulator/Duffy.app"
BUNDLE_ID="com.bigbluefly.Duffy"
OUT="goldie/out/duo"
DUO="${DUO_UDID:-$(xcrun simctl list devices available | grep -m1 'iPhone Duo (' | grep -oE '[0-9A-F-]{36}')}"

read -ra MODES <<<"${DUO_MODES:-unfolded unfolded-portrait folded}"

LOCALES=("$@")
[ ${#LOCALES[@]} -eq 0 ] && LOCALES=(en-US de-DE es-ES fr-FR ja-JP ko-KR uk-UA)

# flow:output-name, in store order
SCENES=(store-01-today:01-today store-03-week:02-week store-02-history:03-history store-04-trophies:04-trophies)

argent() { "$ARGENT" "$@" 2>&1 | grep -vE 'update|Update|dismiss|ACTION REQUIRED|memory|^NOTE|^$'; }

boot_in_locale() {
  local locale=$1
  xcrun simctl boot "$DUO" 2>/dev/null
  xcrun simctl bootstatus "$DUO" -b >/dev/null
  xcrun simctl spawn "$DUO" defaults write -g AppleLanguages -array "$locale"
  xcrun simctl spawn "$DUO" defaults write -g AppleLocale -string "${locale/-/_}"
  # Duffy's simulator-only demo Health data (see HealthKitService.swift)
  xcrun simctl spawn "$DUO" defaults write -g DuffyDemoHealthData -bool YES
  xcrun simctl shutdown "$DUO"
  xcrun simctl boot "$DUO"
  xcrun simctl bootstatus "$DUO" -b >/dev/null
  # Let the system apps that start after a boot settle; argent cannot read the UI tree until they do
  sleep 20
  clear_system_apps
  xcrun simctl install "$DUO" "$APP"
}

# System apps that start after a boot keep argent from reading the UI tree ("ViewInspector RPC
# timed out"); argent's own advice is to terminate them
clear_system_apps() {
  for app in com.apple.family com.apple.Spotlight com.apple.mobilecal; do
    xcrun simctl terminate "$DUO" "$app" 2>/dev/null
  done
}

# Moves the hinge and confirms the expected panel took over: open is the 2007-wide inner panel,
# closed the 1398-wide cover panel
fold_to() {
  local posture=$1 want other
  [ "$posture" = open ] && { want=2007; other=closed; } || { want=1398; other=open; }
  for try in 1 2 3; do
    local width
    width=$("$ARGENT" run fold --udid "$DUO" --posture "$posture" --json 2>/dev/null \
      | grep -oE '"width": *[0-9]+' | head -1 | grep -oE '[0-9]+$')
    sleep 2
    [ "$width" = "$want" ] && return 0
    echo "    fold to $posture showed a ${width:-unknown}-wide panel (try $try)"
    "$ARGENT" run fold --udid "$DUO" --posture "$other" >/dev/null 2>&1
    sleep 2
  done
  return 1
}

# A flow's launch step clears status bar overrides, so pin it again before every screenshot
pin_status_bar() {
  xcrun simctl status_bar "$DUO" override --time 9:41 --dataNetwork wifi --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
  sleep 1
}

# Mean brightness (0-255) of a region given as fractions of the image: file x y width height
brightness() {
  ffmpeg -loglevel error -i "$1" -vf "crop=iw*$4:ih*$5:iw*$2:ih*$3,signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=-" \
    -f null - | grep -oE 'YAVG=[0-9.]+' | head -1 | cut -d= -f2
}

# Turns an unfolded capture into upright landscape. The framebuffer comes out a quarter
# turn either way, so rotate it to landscape, then flip it if the status bar (time and
# Wi-Fi, top right when upright) ended up in the bottom left corner instead.
make_upright() {
  local file=$1
  sips -r 90 "$file" >/dev/null
  local top_right bottom_left
  top_right=$(brightness "$file" 0.90 0.02 0.08 0.12)
  bottom_left=$(brightness "$file" 0.02 0.86 0.08 0.12)
  if awk -v tr="$top_right" -v bl="$bottom_left" 'BEGIN { exit !(bl < tr) }'; then
    sips -r 180 "$file" >/dev/null
  fi
}

# Turns the device. On the unfolded Duo this is the device's orientation, not the UI's:
# Portrait gives the landscape UI and LandscapeLeft the portrait UI.
rotate_to() {
  "$ARGENT" run rotate --udid "$DUO" --orientation "$1" >/dev/null 2>&1
  sleep 2
}

# An upright portrait capture has the status bar in the top right corner; a capture of the
# landscape UI, still sideways in the framebuffer, has it in the top left
portrait_ok() {
  local top_right top_left
  top_right=$(brightness "$1" 0.88 0.01 0.10 0.05)
  top_left=$(brightness "$1" 0.02 0.01 0.10 0.05)
  awk -v tr="$top_right" -v tl="$top_left" 'BEGIN { exit !(tr < tl) }' && return 0
  echo "    capture is not upright portrait"
  return 1
}

run_flow() {
  local flow=$1 report
  for try in 1 2 3; do
    report=$(argent flow run "$flow" --device "$DUO")
    if grep -q '^PASS' <<<"$report"; then return 0; fi
    echo "    $flow failed (try $try): $(grep -m1 '✗' <<<"$report" | cut -c1-160)"
    clear_system_apps
    sleep 5
  done
  return 1
}

# The raw capture's size before any rotation: the panel the posture should show
raw_size_ok() {
  local size
  size=$(sips -g pixelWidth -g pixelHeight "$1" | awk '/pixel/ { print $2 }' | paste -sd x -)
  [ "$2" = open ] && [ "$size" = 2007x2853 ] && return 0
  [ "$2" = closed ] && [ "$size" = 1398x2034 ] && return 0
  echo "    captured $size, wrong panel for $2"
  return 1
}

failed=0
for locale in "${LOCALES[@]}"; do
  echo "> iPhone Duo ($DUO), $locale"
  boot_in_locale "$locale"
  for name in "${MODES[@]}"; do
    case $name in
      unfolded) posture=open; orientation=Portrait ;;
      unfolded-portrait) posture=open; orientation=LandscapeLeft ;;
      folded) posture=closed; orientation=Portrait ;;
      *) echo "  unknown mode $name"; failed=1; continue ;;
    esac
    dir="$OUT/$name/$locale"
    mkdir -p "$dir"
    if ! fold_to "$posture"; then
      echo "  FAILED $name/$locale: the $name panel never took over"
      failed=1
      continue
    fi
    rotate_to "$orientation"
    for scene in "${SCENES[@]}"; do
      flow=${scene%%:*}
      file="$dir/${scene##*:}.png"
      captured=0
      for attempt in 1 2; do
        run_flow "$flow" || break
        pin_status_bar
        argent run screenshot --udid "$DUO" --scale 1 --includeImageInContext false --out "$file" >/dev/null
        if raw_size_ok "$file" "$posture" && { [ $name != unfolded-portrait ] || portrait_ok "$file"; }; then
          captured=1
          break
        fi
        rm -f "$file"
        fold_to "$posture"
        rotate_to "$orientation"
      done
      if [ $captured = 0 ]; then
        echo "  FAILED $name/$locale/${scene##*:}"
        failed=1
        continue
      fi
      # The inner panel's framebuffer is portrait while the UI runs landscape; turn it upright
      [ $name = unfolded ] && make_upright "$file"
      echo "  $name/${scene##*:}"
    done
  done
  rotate_to Portrait
done
exit $failed
