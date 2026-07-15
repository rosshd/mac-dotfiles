#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d /private/tmp/notify-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
fakebin="$tmp/bin"
mkdir -p "$fakebin"

cat > "$fakebin/osascript" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$OSASCRIPT_ARGS"
cat >/dev/null
exit "${OSASCRIPT_EXIT:-0}"
SCRIPT
chmod +x "$fakebin/osascript"

cat > "$fakebin/terminal-notifier" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$TERMINAL_NOTIFIER_ARGS"
SCRIPT
chmod +x "$fakebin/terminal-notifier"

osascript_args="$tmp/osascript.args"
terminal_notifier_args="$tmp/terminal-notifier.args"
title='Captain "quoted" \\ title'
message='Message "quoted" \\ body'

PATH="$fakebin:/usr/bin:/bin" OSASCRIPT_ARGS="$osascript_args" \
  TERMINAL_NOTIFIER_ARGS="$terminal_notifier_args" \
  "$root/bin/notify" --local-only --sound none "$title" "$message"
[ "$(sed -n '1p' "$osascript_args")" = "-" ]
[ "$(sed -n '2p' "$osascript_args")" = "$title" ]
[ "$(sed -n '3p' "$osascript_args")" = "$message" ]
[ ! -f "$terminal_notifier_args" ]

PATH="$fakebin:/usr/bin:/bin" OSASCRIPT_ARGS="$osascript_args" OSASCRIPT_EXIT=1 \
  TERMINAL_NOTIFIER_ARGS="$terminal_notifier_args" NOTIFY_USE_TERMINAL_NOTIFIER=1 \
  "$root/bin/notify" --local-only --sound none "$title" "$message"
rg -Fxq -- '-title' "$terminal_notifier_args"
rg -Fxq -- "$title" "$terminal_notifier_args"
rg -Fxq -- '-message' "$terminal_notifier_args"
rg -Fxq -- "$message" "$terminal_notifier_args"

echo "notify escaping and fallback: ok"
