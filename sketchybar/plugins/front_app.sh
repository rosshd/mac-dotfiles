#!/usr/bin/env bash

APP="${INFO:-$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)}"
case "$APP" in
  iTerm2|Terminal) ICON="term"; COLOR="0xfff5a524" ;;
  "Visual Studio Code"|Code|Cursor) ICON="code"; COLOR="0xff7aa2f7" ;;
  Safari|Arc|Chrome|Firefox) ICON="web"; COLOR="0xff7dcfff" ;;
  *) ICON="app"; COLOR="0xff565f89" ;;
esac

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$APP"
