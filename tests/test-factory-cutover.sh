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

dispatch_skill="$root/plugins/workflow-core/skills/factory-dispatch/SKILL.md"
factory_contract="$root/plugins/workflow-core/references/factory-contract.md"
for required in \
  'send_message_to_thread' \
  'The user should not have to announce that the worker finished' \
  'Initialize an empty active batch before creating the first task' \
  'Immediately record the issue and created owner in the active batch before any other mutation' \
  'local completion becomes `status:verify`' \
  'an external blocker becomes `status:blocked`' \
  'a high-risk pull request awaiting verification becomes `status:verify` plus `needs-human`' \
  'active batch' \
  'final owner settles' \
  'authorized low- and medium-risk shipping' \
  'stop before merge or production activation' \
  'passive statement that no push or pull request occurred' \
  'bounded task-wait capability'; do
  rg -Fq "$required" "$dispatch_skill"
done
for required in \
  'worker-driven handback' \
  'Batch settlement' \
  'Risk and continuation' \
  'status:verify' \
  'needs-human' \
  'standing authorization' \
  'one automatic repair' \
  'The user is not the completion transport'; do
  rg -Fq "$required" "$factory_contract"
done

workflow_doc="$root/docs/WORKFLOW.md"
quicklearn_doc="$root/docs/WORKFLOW-QUICKLEARN.md"
rg -Fq "standing low- and medium-risk factory policy" "$workflow_doc"
rg -Fq "High-risk work may be pushed and opened as a reviewed pull request" "$workflow_doc"
rg -Fq "one repair cycle" "$workflow_doc"
rg -Fq "High-risk work may reach a reviewed pull request" "$quicklearn_doc"
rg -Fq "stop before merge or production activation" "$quicklearn_doc"

review_skill="$root/plugins/workflow-core/skills/ce-code-review/SKILL.md"
shipping_skill="$root/plugins/workflow-core/skills/ce-commit-push-pr/SKILL.md"
rg -Fq 'Treat those repository sources as the evidence boundary' "$review_skill"
rg -Fq 'Apply at most one repair cycle automatically' "$shipping_skill"
rg -Fq "standing risk policy" "$shipping_skill"

workflow="$root/.github/workflows/ci.yml"
[ -f "$workflow" ]
for required_line in \
  'name: Repository gate' \
  '  pull_request:' \
  '  push:' \
  '      - main' \
  '    name: Repository gate' \
  '    runs-on: macos-latest' \
  '      - uses: actions/checkout@v4' \
  '        run: brew install ripgrep' \
  '        run: make check'; do
  rg -Fxq "$required_line" "$workflow"
done
[ "$(rg -c '^[[:space:]]+run: make check$' "$workflow")" -eq 1 ]

echo "factory cutover contract: ok"
