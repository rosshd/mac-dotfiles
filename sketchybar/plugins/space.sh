#!/usr/bin/env bash

SID="${NAME#ws.}"
FOCUSED="${FOCUSED:-${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}}"

if [ "$SID" = "$FOCUSED" ] || [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    icon.color=0xfff5a524 \
    background.color=0x33111827 \
    background.border_width=1 \
    background.border_color=0xfff5a524
else
  sketchybar --set "$NAME" \
    icon.color=0xff565f89 \
    background.color=0x00000000 \
    background.border_width=0
fi
