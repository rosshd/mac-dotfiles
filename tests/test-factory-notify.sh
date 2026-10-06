#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s "$root/tests" -p test_factory_notify.py -v
printf 'malformed input' | "$root/bin/factory-notify-hook" | rg -Fxq '{}'
