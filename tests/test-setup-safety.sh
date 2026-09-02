#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
setup="$root/setup.sh"

required_dirs_line="$(rg -n -F '"$HOME/Developer/tools" \' "$setup" | cut -d: -f1)"
treehouse_line="$(rg -n -F 'ln -sfn "$(go env GOPATH)/bin/treehouse"' "$setup" | cut -d: -f1)"
[ "$required_dirs_line" -lt "$treehouse_line" ]
for directory in \
  '"$HOME/Developer/projects" \' \
  '"$HOME/Developer/sandbox" \' \
  '"$HOME/School"'; do
  rg -Fq "$directory" "$setup"
done
for target in .codex .claude .config/opencode; do
  rg -Fq "home.file.\"$target/skills/axi\"" "$root/nix/home.nix"
done
if rg -Fq 'home.file.".codex/skills" =' "$root/nix/home.nix"; then
  echo "Home Manager must not replace the whole Codex skill root" >&2
  exit 1
fi

if rg -Fq '"$HOME/.config/nvim" \' "$setup"; then
  echo "setup must not pre-create the managed Neovim link target" >&2
  exit 1
fi
for target in \
  '"$DOTFILES/nvim" "$HOME/.config/nvim"'; do
  rg -Fq "link_managed_directory $target" "$setup"
done
for target in \
  '"$DOTFILES/agents/skills" "$HOME/.codex/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.claude/skills"' \
  '"$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"'; do
  rg -Fq "publish_managed_skills $target" "$setup"
  if rg -Fq "link_managed_directory $target" "$setup"; then
    echo "setup must publish managed skills without replacing the whole skill root" >&2
    exit 1
  fi
done
rg -Fq 'ln -sfn "$DOTFILES/agents" "$HOME/agents"' "$setup"
rg -Fq '"$DOTFILES/agents/integrations/raycast/networking-capture.sh"' "$setup"
rg -Fq '"$HOME/Library/Application Support/Raycast/scripts/networking-capture.sh"' "$setup"
rg -Fq '"$HOME/Library/Application Support/Raycast/scripts/networking-calendar.sh"' "$setup"

rg -Fq 'NO_MISTAKES_VERSION="v1.37.0"' "$setup"
rg -Fq 'no_mistakes_managed="$HOME/.no-mistakes/bin/no-mistakes"' "$setup"
rg -Fq '"$no_mistakes_managed" --version' "$setup"
rg -Fq 'ln -sfn "$no_mistakes_managed" "$HOME/.local/bin/no-mistakes"' "$setup"
rg -Fq 'PATH="$HOME/.local/bin:$PATH"' "$setup"
rg -Fq 'export PATH' "$setup"
rg -Fq 'no_mistakes_active="$(command -v no-mistakes' "$setup"
rg -Fq 'Active no-mistakes executable is not the managed' "$setup"
if rg -Fq 'if ! command -v no-mistakes' "$setup"; then
  echo "setup must reconcile the managed no-mistakes pin regardless of PATH" >&2
  exit 1
fi
rg -Fq 'NO_MISTAKES_ARCHIVE_SHA256="8f2ac871c0ca35dae957bf3e20eb7cafcfd5fc7de622c46e5e519081924749a1"' "$setup"
rg -Fq 'NO_MISTAKES_ARCHIVE_SHA256="d081ac49c7c40473bf51e759639be5ede7adb735407207131bc7eadcb739d656"' "$setup"
rg -Fq "shasum -a 256 -c -" "$setup"
if rg -Fq 'releases/latest' "$setup" || rg -Fq 'no-mistakes/main/docs/install.sh' "$setup"; then
  echo "no-mistakes installation must not resolve mutable upstream state" >&2
  exit 1
fi
if rg -Fq 'no-mistakes/main/docs/install.sh' "$root/docs/TOOLS.md"; then
  echo "tool documentation must use the verified setup path" >&2
  exit 1
fi
if rg -Fq 'herdr integration install "$integration" || true' "$setup"; then
  echo "Herdr integration failures must not be ignored" >&2
  exit 1
fi

setup_tmp="$(mktemp -d /private/tmp/setup-safety-test.XXXXXX)"
trap 'rm -rf "$setup_tmp"' EXIT
mkdir -p "$setup_tmp/.local/bin" "$setup_tmp/.no-mistakes/bin"
printf '%s\n' '#!/usr/bin/env bash' 'printf "no-mistakes v1.37.0\\n"' > "$setup_tmp/.no-mistakes/bin/no-mistakes"
chmod +x "$setup_tmp/.no-mistakes/bin/no-mistakes"
sed -n '/^NO_MISTAKES_VERSION=/,/^# ---/p' "$setup" | sed '$d' | \
  HOME="$setup_tmp" PATH="/usr/bin:/bin" bash
[ "$(readlink "$setup_tmp/.local/bin/no-mistakes")" = "$setup_tmp/.no-mistakes/bin/no-mistakes" ]

skill_source="$setup_tmp/dotfiles-skills"
skill_root="$setup_tmp/.codex/skills"
mkdir -p "$skill_source/managed" "$skill_root/.system" "$skill_root/personal"
mv "$skill_root" "$skill_root.pre-dotfiles.20260901000000"
ln -s "$skill_source" "$skill_root"
source <(sed -n '/^link_managed_directory()/,/^# treehouse:/p' "$setup" | sed '$d')
publish_managed_skills "$skill_source" "$skill_root"
[ -d "$skill_source/managed" ]
[ ! -L "$skill_source/managed" ]
[ -d "$skill_root/.system" ]
[ -d "$skill_root/personal" ]
[ "$(readlink "$skill_root/managed")" = "$skill_source/managed" ]

echo "setup safety contract: ok"
