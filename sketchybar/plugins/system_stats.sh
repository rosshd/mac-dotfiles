#!/usr/bin/env bash

case "$1" in
  battery)
    PERCENT="$(pmset -g batt | awk 'NR==2 { match($0, /[0-9]+%/); print substr($0, RSTART, RLENGTH-1) }')"
    STATE="$(pmset -g batt | awk -F"'" 'NR==1 { print $2 }')"
    ICON="󰁹"
    COLOR="0xff7aa2f7"
    if [ "$STATE" = "AC Power" ]; then ICON="󰂄"; COLOR="0xffa6e08c"; fi
    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENT:-?}%"
    ;;
  wifi)
    SSID="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/ {print $2; exit}')"
    [ -z "$SSID" ] && SSID="Wi-Fi"
    sketchybar --set "$NAME" label="$SSID"
    ;;
  cpu)
    LOAD="$(sysctl -n vm.loadavg | awk '{print $2}')"
    sketchybar --set "$NAME" label="$LOAD"
    ;;
esac
