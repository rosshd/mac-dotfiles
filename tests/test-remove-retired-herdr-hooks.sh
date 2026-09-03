#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
helper="$root/scripts/remove-retired-herdr-hooks.py"
tmp="$(mktemp -d /private/tmp/remove-retired-herdr-hooks-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/home/.claude" "$tmp/home/.copilot"
cat > "$tmp/home/.claude/settings.json" <<JSON
{
  "theme": "dark",
  "hooks": {
    "Notification": [{"matcher": "", "hooks": [{"type": "command", "command": "notify"}]}],
    "SessionStart": [
      {"matcher": "*", "hooks": [
        {"type": "command", "command": "bash '$tmp/home/.claude/hooks/herdr-agent-state.sh' session", "timeout": 10},
        {"type": "command", "command": "keep-claude", "timeout": 5}
      ]}
    ],
    "Stop": [{"matcher": "", "hooks": [{"type": "command", "command": "complete"}]}]
  },
  "permissions": {"defaultMode": "auto"}
}
JSON
cat > "$tmp/home/.copilot/settings.json" <<JSON
{
  "hooks": {
    "SessionStart": [
      {"type": "command", "bash": "bash '$tmp/home/.copilot/hooks/herdr-agent-state.sh'", "timeoutSec": 10},
      {"type": "command", "bash": "keep-copilot", "timeoutSec": 5}
    ]
  },
  "unrelated": true
}
JSON
chmod 600 "$tmp/home/.claude/settings.json" "$tmp/home/.copilot/settings.json"

python3 "$helper" claude "$tmp/home/.claude/settings.json" --home "$tmp/home"
python3 "$helper" copilot "$tmp/home/.copilot/settings.json" --home "$tmp/home"

python3 - "$tmp/home/.claude/settings.json" "$tmp/home/.copilot/settings.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    claude = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    copilot = json.load(handle)

claude_commands = [
    hook["command"]
    for group in claude["hooks"]["SessionStart"]
    for hook in group["hooks"]
]
assert claude_commands == ["keep-claude"]
assert claude["hooks"]["Notification"][0]["hooks"][0]["command"] == "notify"
assert claude["hooks"]["Stop"][0]["hooks"][0]["command"] == "complete"
assert claude["permissions"] == {"defaultMode": "auto"}
assert claude["theme"] == "dark"

assert copilot["hooks"]["SessionStart"] == [
    {"type": "command", "bash": "keep-copilot", "timeoutSec": 5}
]
assert copilot["unrelated"] is True
PY
[ "$(/usr/bin/stat -f '%Lp' "$tmp/home/.claude/settings.json")" = "600" ]
[ "$(/usr/bin/stat -f '%Lp' "$tmp/home/.copilot/settings.json")" = "600" ]

claude_checksum="$(shasum -a 256 "$tmp/home/.claude/settings.json")"
copilot_checksum="$(shasum -a 256 "$tmp/home/.copilot/settings.json")"
python3 "$helper" claude "$tmp/home/.claude/settings.json" --home "$tmp/home"
python3 "$helper" copilot "$tmp/home/.copilot/settings.json" --home "$tmp/home"
[ "$(shasum -a 256 "$tmp/home/.claude/settings.json")" = "$claude_checksum" ]
[ "$(shasum -a 256 "$tmp/home/.copilot/settings.json")" = "$copilot_checksum" ]

printf '{"hooks":{"SessionStart":[]}}\n' > "$tmp/no-match.json"
no_match_checksum="$(shasum -a 256 "$tmp/no-match.json")"
python3 "$helper" claude "$tmp/no-match.json" --home "$tmp/home"
[ "$(shasum -a 256 "$tmp/no-match.json")" = "$no_match_checksum" ]

printf '{invalid json\n' > "$tmp/invalid.json"
invalid_checksum="$(shasum -a 256 "$tmp/invalid.json")"
if python3 "$helper" claude "$tmp/invalid.json" --home "$tmp/home" 2>/dev/null; then
  echo "invalid settings must fail closed" >&2
  exit 1
fi
[ "$(shasum -a 256 "$tmp/invalid.json")" = "$invalid_checksum" ]

echo "retired Herdr hook cleanup: ok"
