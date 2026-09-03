#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
setup="$root/setup.sh"

for directory in \
  '"$HOME/Developer/projects" \' \
  '"$HOME/Developer/sandbox" \' \
  '"$HOME/School"'; do
  rg -Fq "$directory" "$setup"
done

if rg -Fq '"$HOME/.config/nvim" \' "$setup"; then
  echo "setup must not pre-create the managed Neovim link target" >&2
  exit 1
fi
rg -Fq 'link_managed_directory "$DOTFILES/nvim" "$HOME/.config/nvim"' "$setup"

for target in \
  '"$DOTFILES/agents/skills" "$HOME/.codex/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.claude/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"'; do
  rg -Fq "publish_managed_skills $target" "$setup"
done

for target in .codex .claude .config/opencode; do
  rg -Fq "home.file.\"$target/skills/axi\"" "$root/nix/home.nix"
done
if rg -Fq 'home.file.".codex/skills" =' "$root/nix/home.nix"; then
  echo "Home Manager must not replace the whole Codex skill root" >&2
  exit 1
fi

for script in ship agent agent-doctor plan-artifact voice-vocab doctor notify networking networking-mcp rebuild-mac; do
  rg -q -e "for script in .*${script}" "$setup"
  rg -Fq "home.file.\".local/bin/$script\"" "$root/nix/home.nix"
done

for forbidden in \
  'go install github.com/kunchenguid/treehouse' \
  'npm install -g gnhf' \
  'herdr integration install' \
  'daemon restart' \
  'git clone https://github.com/kunchenguid/firstmate'; do
  if rg -Fq "$forbidden" "$setup"; then
    echo "setup still activates retired workflow: $forbidden" >&2
    exit 1
  fi
done

tmp="$(mktemp -d /private/tmp/setup-safety-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p \
  "$tmp/.local/bin" \
  "$tmp/.codex/skills" \
  "$tmp/.claude/skills" \
  "$tmp/.config/opencode/skills" \
  "$tmp/.no-mistakes/bin" \
  "$tmp/.gnhf/runs/history" \
  "$tmp/Developer/tools/firstmate/.git" \
  "$tmp/Developer/worktrees/preserved"
printf 'preserved binary\n' > "$tmp/.no-mistakes/bin/no-mistakes"
printf 'preserved history\n' > "$tmp/.gnhf/runs/history/run.log"
printf 'preserved repository\n' > "$tmp/Developer/tools/firstmate/.git/config"
printf 'preserved worktree\n' > "$tmp/Developer/worktrees/preserved/README"
ln -s "$root/bin/captain" "$tmp/.local/bin/captain"
ln -s "$tmp/.no-mistakes/bin/no-mistakes" "$tmp/.local/bin/no-mistakes"
ln -s "$root/agents/skills/no-mistakes" "$tmp/.codex/skills/no-mistakes"

function_source="$(sed -n '/^remove_managed_link()/,/^# gh-dash:/p' "$setup" | sed '$d')"
function_file="$tmp/setup-functions.sh"
printf '%s\n' "$function_source" > "$function_file"
# shellcheck source=/dev/null
source "$function_file"
remove_managed_link "$tmp/.local/bin/captain" "$root/bin/captain"
remove_managed_link "$tmp/.local/bin/no-mistakes" "$tmp/.no-mistakes/bin/no-mistakes"
remove_managed_link "$tmp/.codex/skills/no-mistakes" "$root/agents/skills/no-mistakes"

rg -Fq 'remove_managed_link "$HOME/.local/bin/no-mistakes" "$HOME/.no-mistakes/bin/no-mistakes"' "$setup"
rg -Fq 'remove_managed_link "$skill_root/no-mistakes" "$DOTFILES/agents/skills/no-mistakes"' "$setup"
rg -Fq 'HERDR_ARCHIVE_ROOT="$HOME/.factory-migration/archive/' "$setup"
rg -Fq 'claude "$HOME/.claude/settings.json" --home "$HOME" \' "$setup"
rg -Fq 'copilot "$HOME/.copilot/settings.json" --home "$HOME" \' "$setup"
if [ "$(rg -Fc -- '--archive-root "$HERDR_ARCHIVE_ROOT"' "$setup")" -ne 2 ]; then
  echo "both retired hook cleanups must use the rollback archive" >&2
  exit 1
fi

[ ! -L "$tmp/.local/bin/captain" ]
[ ! -L "$tmp/.local/bin/no-mistakes" ]
[ ! -L "$tmp/.codex/skills/no-mistakes" ]
[ -f "$tmp/.no-mistakes/bin/no-mistakes" ]
[ -f "$tmp/.gnhf/runs/history/run.log" ]
[ -f "$tmp/Developer/tools/firstmate/.git/config" ]
[ -f "$tmp/Developer/worktrees/preserved/README" ]

skill_source="$tmp/dotfiles-skills"
skill_root="$tmp/unmanaged-skills"
mkdir -p "$skill_source/managed" "$skill_root/.system" "$skill_root/personal"
publish_managed_skills "$skill_source" "$skill_root"
[ -d "$skill_root/.system" ]
[ -d "$skill_root/personal" ]
[ "$(readlink "$skill_root/managed")" = "$skill_source/managed" ]

rg -Fq 'ln -sfn "$DOTFILES/agents" "$HOME/agents"' "$setup"
rg -Fq '"$DOTFILES/agents/integrations/raycast/networking-capture.sh"' "$setup"
rg -Fq '"$HOME/Library/Application Support/Raycast/scripts/networking-capture.sh"' "$setup"
rg -Fq '"$HOME/Library/Application Support/Raycast/scripts/networking-calendar.sh"' "$setup"

echo "setup safety and state preservation contract: ok"
