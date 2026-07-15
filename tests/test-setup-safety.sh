#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
setup="$root/setup.sh"

required_dirs_line="$(rg -n -F 'mkdir -p "$HOME/.local/bin" "$HOME/Developer/tools"' "$setup" | cut -d: -f1)"
treehouse_line="$(rg -n -F 'ln -sfn "$(go env GOPATH)/bin/treehouse"' "$setup" | cut -d: -f1)"
[ "$required_dirs_line" -lt "$treehouse_line" ]

if rg -Fq '"$HOME/.config/nvim" \' "$setup"; then
  echo "setup must not pre-create the managed Neovim link target" >&2
  exit 1
fi
for target in \
  '"$DOTFILES/nvim" "$HOME/.config/nvim"' \
  '"$DOTFILES/agents/skills" "$HOME/.codex/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.claude/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"'; do
  rg -Fq "link_managed_directory $target" "$setup"
done

rg -Fq 'NO_MISTAKES_REV="2bbbc143bd4520056e97957883a02615657b2a62"' "$setup"
rg -Fq 'NO_MISTAKES_INSTALL_SHA256="502c518c70ac4ed49ba0e42816db4b1312caad44760fa3619ca4bd41f786678b"' "$setup"
if rg -Fq 'no-mistakes/main/docs/install.sh' "$setup"; then
  echo "no-mistakes installer must use the pinned revision" >&2
  exit 1
fi
if rg -Fq 'herdr integration install "$integration" || true' "$setup"; then
  echo "Herdr integration failures must not be ignored" >&2
  exit 1
fi

echo "setup safety contract: ok"
