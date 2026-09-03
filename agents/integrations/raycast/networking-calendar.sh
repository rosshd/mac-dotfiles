#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Import Networking Calendar
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName Networking
# @raycast.icon 📅

set -euo pipefail

"$HOME/.local/bin/networking" calendar --days-back 1 --days-forward 14
