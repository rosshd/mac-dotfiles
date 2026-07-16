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

echo "setup safety contract: ok"
