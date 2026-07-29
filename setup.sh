#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required before running this setup."
  echo "Install it from https://brew.sh, then rerun setup.sh."
  exit 1
fi

echo "Installing terminal workflow packages..."
brew update
brew bundle --file "$DOTFILES/Brewfile"

# --- Agent orchestration stack -------------------------------------------------
# These replace the local helper scripts noted in docs/TOOLS.md:
#   treehouse -> wt, no-mistakes -> make validate, gnhf -> bounded loops,
#   firstmate -> crew, lavish -> plan-artifact.
echo "Installing agent orchestration stack..."

mkdir -p "$HOME/.local/bin" "$HOME/Developer/tools"

link_managed_directory() {
  local source="$1"
  local target="$2"
  local backup

  if [ -L "$target" ] || [ ! -e "$target" ]; then
    ln -sfn "$source" "$target"
    return
  fi

  backup="$target.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "  moved existing $target to $backup"
  ln -s "$source" "$target"
}

# treehouse: Git worktree orchestrator (Go module -> ~/go/bin).
go install github.com/kunchenguid/treehouse@v2.0.0
ln -sfn "$(go env GOPATH)/bin/treehouse" "$HOME/.local/bin/treehouse"

# gnhf + lavish-axi: published npm packages, installed globally.
npm install -g gnhf@0.1.41 lavish-axi@0.1.31

# lavish-axi: install agent hooks (Claude Code, Codex, OpenCode).
lavish-axi setup hooks

# Herdr: terminal-native agent multiplexer and agent state surface.
integration_failures=()
for integration in codex claude opencode copilot; do
  if ! herdr integration install "$integration"; then
    integration_failures+=("$integration")
  fi
done
if [ "${#integration_failures[@]}" -gt 0 ]; then
  printf 'Herdr integration installation failed: %s\n' "${integration_failures[*]}" >&2
  echo "Rerun setup after resolving the reported integration errors." >&2
  exit 1
fi

# gh-dash: terminal dashboard for GitHub PRs and issues.
gh extension install dlvhdr/gh-dash 2>/dev/null || gh extension upgrade dlvhdr/gh-dash

# Agent skills (lavish, axi, no-mistakes, ...) are vendored under agents/skills/
# and published to all three agents by the symlinks below -- no fetch needed here.
# To refresh or add one, run from the repo root, then move it out of the
# CLI's default .agents/skills/ into agents/skills/:
#   npx --yes skills add kunchenguid/<skill>

# firstmate: cloned repo wrapper (bin/firstmate execs codex inside it).
FM_HOME="$HOME/Developer/tools/firstmate"
if [ ! -d "$FM_HOME/.git" ]; then
  git clone https://github.com/kunchenguid/firstmate "$FM_HOME"
fi

# no-mistakes: local git proxy that validates changes through an AI pipeline
# before pushing. Installs to ~/.no-mistakes/bin, symlinks ~/.local/bin/no-mistakes,
# and starts a daemon.
NO_MISTAKES_VERSION="v1.37.0"
no_mistakes_managed="$HOME/.no-mistakes/bin/no-mistakes"
no_mistakes_install=1
if [ -x "$no_mistakes_managed" ] \
  && "$no_mistakes_managed" --version 2>&1 | grep -Fq "$NO_MISTAKES_VERSION"; then
  no_mistakes_install=0
fi
if [ "$no_mistakes_install" -eq 1 ]; then
  case "$(uname -m)" in
    arm64|aarch64)
      no_mistakes_arch="arm64"
      NO_MISTAKES_ARCHIVE_SHA256="8f2ac871c0ca35dae957bf3e20eb7cafcfd5fc7de622c46e5e519081924749a1"
      ;;
    x86_64|amd64)
      no_mistakes_arch="amd64"
      NO_MISTAKES_ARCHIVE_SHA256="d081ac49c7c40473bf51e759639be5ede7adb735407207131bc7eadcb739d656"
      ;;
    *)
      echo "Unsupported architecture for no-mistakes: $(uname -m)" >&2
      exit 1
      ;;
  esac
  no_mistakes_archive="no-mistakes-$NO_MISTAKES_VERSION-darwin-$no_mistakes_arch.tar.gz"
  no_mistakes_tmp="$(mktemp -d)"
  trap 'rm -rf "$no_mistakes_tmp"' EXIT
  curl -fsSL \
    "https://github.com/kunchenguid/no-mistakes/releases/download/$NO_MISTAKES_VERSION/$no_mistakes_archive" \
    -o "$no_mistakes_tmp/$no_mistakes_archive"
  printf '%s  %s\n' "$NO_MISTAKES_ARCHIVE_SHA256" "$no_mistakes_tmp/$no_mistakes_archive" | shasum -a 256 -c -
  tar -xzf "$no_mistakes_tmp/$no_mistakes_archive" -C "$no_mistakes_tmp"
  mkdir -p "$HOME/.no-mistakes/bin"
  install -m 755 "$no_mistakes_tmp/no-mistakes" "$no_mistakes_managed"
  "$no_mistakes_managed" --version 2>&1 | grep -Fq "$NO_MISTAKES_VERSION"
  "$no_mistakes_managed" daemon restart >/dev/null
  rm -rf "$no_mistakes_tmp"
  trap - EXIT
fi
ln -sfn "$no_mistakes_managed" "$HOME/.local/bin/no-mistakes"
PATH="$HOME/.local/bin:$PATH"
export PATH
hash -r
no_mistakes_active="$(command -v no-mistakes 2>/dev/null || true)"
if [ "$no_mistakes_active" != "$no_mistakes_managed" ] \
  && [ "$(readlink "$no_mistakes_active" 2>/dev/null || true)" != "$no_mistakes_managed" ]; then
  echo "Active no-mistakes executable is not the managed $NO_MISTAKES_VERSION pin: ${no_mistakes_active:-missing}" >&2
  exit 1
fi
"$no_mistakes_active" --version 2>&1 | grep -Fq "$NO_MISTAKES_VERSION"
# ------------------------------------------------------------------------------

mkdir -p \
  "$HOME/.config/fish" \
  "$HOME/.config" \
  "$HOME/.config/wezterm" \
  "$HOME/.config/karabiner" \
  "$HOME/.config/voice" \
  "$HOME/.config/herdr" \
  "$HOME/.local/bin" \
  "$HOME/.no-mistakes" \
  "$HOME/.codex" \
  "$HOME/.claude" \
  "$HOME/.config/opencode" \
  "$HOME/.copilot" \
  "$HOME/.gemini"

ln -sfn "$DOTFILES/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sfn "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DOTFILES/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
ln -sfn "$DOTFILES/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
link_managed_directory "$DOTFILES/nvim" "$HOME/.config/nvim"
ln -sfn "$DOTFILES/voice/vocabulary.md" "$HOME/.config/voice/vocabulary.md"
ln -sfn "$DOTFILES/herdr/config.toml" "$HOME/.config/herdr/config.toml"
ln -sfn "$DOTFILES/no-mistakes/config.yaml" "$HOME/.no-mistakes/config.yaml"
mkdir -p "$HOME/.config/gh-dash"
ln -sfn "$DOTFILES/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"

for script in ship agent agent-doctor wt crew captain plan-artifact voice-vocab doctor firstmate notify networking networking-mcp fleet tmux-resurrect-clean clean-reboot rebuild-mac; do
  ln -sfn "$DOTFILES/bin/$script" "$HOME/.local/bin/$script"
  chmod +x "$DOTFILES/bin/$script"
done
mkdir -p "$HOME/Library/Application Support/Raycast/scripts"
ln -sfn "$DOTFILES/agents/integrations/raycast/networking-capture.sh" \
  "$HOME/Library/Application Support/Raycast/scripts/networking-capture.sh"
ln -sfn "$DOTFILES/agents/integrations/raycast/networking-calendar.sh" \
  "$HOME/Library/Application Support/Raycast/scripts/networking-calendar.sh"

ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$DOTFILES/agents/config/codex-hooks.json" "$HOME/.codex/hooks.json"
ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.copilot/copilot-instructions.md"
ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.gemini/GEMINI.md"
ln -sfn "$DOTFILES/agents" "$HOME/agents"
# Opinions/voice files that AGENTS.md defers to, kept lean for token efficiency.
ln -sfn "$DOTFILES/STYLE.md" "$HOME/STYLE.md"
ln -sfn "$DOTFILES/agents/VOICE.md" "$HOME/VOICE.md"
link_managed_directory "$DOTFILES/agents/skills" "$HOME/.codex/skills"
link_managed_directory "$DOTFILES/agents/skills" "$HOME/.claude/skills"
link_managed_directory "$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"

# tmux session persistence: tpm + resurrect/continuum (.tmux.conf lists the plugins).
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
# A detached session sources .tmux.conf so tpm exports its path; then install plugins.
tmux kill-session -t _tpm_install 2>/dev/null || true
tmux new-session -d -s _tpm_install 2>/dev/null || true
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || \
  echo "  tpm: open tmux and press 'prefix + I' to finish installing plugins." >&2
tmux kill-session -t _tpm_install 2>/dev/null || true

# Make fish the default login shell (needs sudo; safe to re-run).
FISH_BIN="$(command -v fish)"
if ! grep -qxF "$FISH_BIN" /etc/shells; then
  echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
fi
[ "$SHELL" = "$FISH_BIN" ] || chsh -s "$FISH_BIN"

# Prefer native macOS window management with predictable Mission Control behavior.
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.dock mru-spaces -bool true
defaults write com.apple.spaces spans-displays -bool false
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write -g NSQuitAlwaysKeepsWindows -bool false
defaults write -g ApplePersistenceIgnoreState -bool true
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
for app_id in \
  com.apple.Terminal \
  com.googlecode.iterm2 \
  com.github.wez.wezterm \
  com.openai.codex \
  com.knollsoft.Rectangle \
  com.raycast.macos \
  com.spotify.client \
  io.tailscale.ipn.macos \
  org.pqrs.Karabiner-Elements.Settings \
  ru.starmel.OpenSuperWhisper \
  org.mozilla.firefox \
  com.google.Chrome \
  com.microsoft.VSCode \
  com.anthropic.claudefordesktop; do
  defaults write "$app_id" NSQuitAlwaysKeepsWindows -bool false
  defaults write "$app_id" ApplePersistenceIgnoreState -bool true
done

osascript <<'APPLESCRIPT' >/dev/null 2>&1 || true
tell application "System Events"
  if not (exists login item "Rectangle") then
    make login item at end with properties {path:"/Applications/Rectangle.app", hidden:true}
  end if
end tell
APPLESCRIPT

# Keep screenshots in a stable folder.
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

echo "Setup complete. Restart the Dock or log out/in for macOS defaults to fully apply."
echo "Run 'doctor' to validate the toolchain."
echo "Open WezTerm; it will start the 'ship' tmux workspace."
