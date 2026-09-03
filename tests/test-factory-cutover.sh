#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

retired_paths=(
  agents/prompts/templates/fleet-brief.md
  agents/skills/no-mistakes
  bin/captain
  bin/crew
  bin/firstmate
  bin/fleet
  bin/wt
  herdr
  no-mistakes
)
for path in "${retired_paths[@]}"; do
  if [ -e "$root/$path" ] || [ -L "$root/$path" ]; then
    echo "retired source path remains: $path" >&2
    exit 1
  fi
done

active_surfaces=(
  .tmux.conf
  Brewfile
  README.md
  STYLE.md
  agents/AGENTS.md
  agents/config/codex-hooks.json
  agents/skills/babysit-prs/SKILL.md
  bin/doctor
  docs/CODING_TEMPLATES.md
  docs/KEYBINDS.md
  docs/REMAINING.md
  docs/REPRODUCIBILITY.md
  docs/TOOLS.md
  docs/WORKFLOW-QUICKLEARN.md
  docs/WORKFLOW.md
  fish/config.fish
  gh-dash/config.yml
  nix/darwin.nix
  nix/home.nix
  voice/vocabulary.md
)
retired_pattern='captain|fleet|gnhf|good[[:space:]-]*night[[:space:]-]*have[[:space:]-]*fun|tree[[:space:]-]*house|no[[:space:]-]*mistakes|herdr|first[[:space:]-]*mate|crew([[:space:]-]*mate)?|lavish'
if rg -n -i "$retired_pattern" "${active_surfaces[@]/#/$root/}"; then
  echo "active source still exposes the retired workflow" >&2
  exit 1
fi

for forbidden in \
  'go install github.com/kunchenguid/treehouse' \
  'npm install -g gnhf' \
  'herdr integration install' \
  'daemon restart' \
  'git clone https://github.com/kunchenguid/firstmate'; do
  if rg -Fq "$forbidden" "$root/setup.sh"; then
    echo "setup still activates retired workflow: $forbidden" >&2
    exit 1
  fi
done

for required in \
  'GitHub Issues' \
  'managed worktree' \
  'make check' \
  'exact head' \
  'independent review' \
  'risk' \
  'release' \
  'next work'; do
  rg -Fiq "$required" "$root/docs/WORKFLOW.md"
done

for skill in \
  ce-work \
  ce-code-review \
  ce-commit-push-pr \
  factory-bootstrap \
  factory-dispatch; do
  [ -f "$root/plugins/workflow-core/skills/$skill/SKILL.md" ]
  rg -Fq "$skill" "$root/bin/doctor"
done

for command in codex gh tmux nvim; do
  rg -q -e "(^|[[:space:]\"'])${command}([[:space:]\"']|$)" "$root/bin/doctor"
done
rg -Fq 'gh-dash extension' "$root/bin/doctor"
rg -Fq 'terminal-notifier' "$root/bin/doctor"

python3 - "$root/agents/config/codex-hooks.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    hooks = json.load(handle)["hooks"]

assert set(hooks) == {"Stop"}
commands = [
    hook["command"]
    for group in hooks["Stop"]
    for hook in group["hooks"]
    if hook["type"] == "command"
]
assert len(commands) == 1
assert "/notify " in commands[0]
assert "Codex done" in commands[0]
assert hooks["Stop"][0]["hooks"][0]["statusMessage"] == "Sending completion notification"
PY

rg -Fq 'factory-issue.md' "$root/docs/WORKFLOW.md"
[ -f "$root/agents/prompts/templates/factory-issue.md" ]

echo "factory cutover contract: ok"
