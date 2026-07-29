#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Capture Networking Note
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Networking
# @raycast.icon 👥
# @raycast.argument1 {"type":"text","placeholder":"Dictate or paste details"}

set -euo pipefail

"$HOME/.local/bin/networking" capture --source raycast -- "$1"
"$HOME/.local/bin/notify" --local-only --sound none \
  "Networking note captured" \
  "Codex can process it with: networking process"
