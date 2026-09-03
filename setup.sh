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

mkdir -p \
  "$HOME/.local/bin" \
  "$HOME/Developer/projects" \
  "$HOME/Developer/sandbox" \
  "$HOME/School"

remove_managed_link() {
  local target="$1"
  local expected="$2"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$expected" ]; then
    rm "$target"
    echo "  removed retired managed link $target"
  fi
}

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

publish_managed_skills() {
  local source_root="$1"
  local target_root="$2"
  local source_resolved target_resolved backup restore skill

  source_resolved="$(cd "$source_root" && pwd -P)"
  if [ -L "$target_root" ]; then
    target_resolved="$(realpath "$target_root" 2>/dev/null || true)"
    if [ "$target_resolved" = "$source_resolved" ]; then
      restore=""
      for backup in "$target_root".pre-dotfiles.*; do
        [ -d "$backup" ] || continue
        restore="$backup"
      done
      rm "$target_root"
      if [ -n "$restore" ]; then
        mv "$restore" "$target_root"
        echo "  restored existing skill root from $restore"
      else
        mkdir -p "$target_root"
      fi
    fi
  fi

  mkdir -p "$target_root"
  for skill in "$source_root"/*; do
    [ -d "$skill" ] || continue
    link_managed_directory "$skill" "$target_root/$(basename "$skill")"
  done
}

# gh-dash: terminal dashboard for GitHub PRs and issues.
gh extension install dlvhdr/gh-dash 2>/dev/null || gh extension upgrade dlvhdr/gh-dash

# Agent skills are vendored under agents/skills/ and published to all three
# agents below.
# To refresh or add one, run from the repo root, then move it out of the
# CLI's default .agents/skills/ into agents/skills/:
#   npx --yes skills add kunchenguid/<skill>

# Remove only links created by earlier revisions.
# Installed binaries, repositories, databases, logs, and worktrees stay intact.
for script in captain crew firstmate fleet wt; do
  remove_managed_link "$HOME/.local/bin/$script" "$DOTFILES/bin/$script"
done
remove_managed_link "$HOME/.local/bin/treehouse" "$HOME/go/bin/treehouse"
remove_managed_link "$HOME/.local/bin/no-mistakes" "$HOME/.no-mistakes/bin/no-mistakes"
remove_managed_link "$HOME/.config/herdr/config.toml" "$DOTFILES/herdr/config.toml"
remove_managed_link "$HOME/.no-mistakes/config.yaml" "$DOTFILES/no-mistakes/config.yaml"
for skill_root in "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
  remove_managed_link "$skill_root/no-mistakes" "$DOTFILES/agents/skills/no-mistakes"
done
HERDR_ARCHIVE_ROOT="$HOME/.factory-migration/archive/$(date -u +%Y-%m-%dT%H%M%SZ)-residual-herdr-hooks-$$"
python3 "$DOTFILES/scripts/remove-retired-herdr-hooks.py" \
  claude "$HOME/.claude/settings.json" --home "$HOME" \
  --archive-root "$HERDR_ARCHIVE_ROOT"
python3 "$DOTFILES/scripts/remove-retired-herdr-hooks.py" \
  copilot "$HOME/.copilot/settings.json" --home "$HOME" \
  --archive-root "$HERDR_ARCHIVE_ROOT"

mkdir -p \
  "$HOME/.config/fish" \
  "$HOME/.config" \
  "$HOME/.config/wezterm" \
  "$HOME/.config/karabiner" \
  "$HOME/.config/voice" \
  "$HOME/.local/bin" \
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
mkdir -p "$HOME/.config/gh-dash"
ln -sfn "$DOTFILES/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"

for script in ship agent agent-doctor plan-artifact voice-vocab doctor notify networking networking-mcp tmux-resurrect-clean clean-reboot rebuild-mac spotify-popup focus-app spotify-mute; do
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
publish_managed_skills "$DOTFILES/agents/skills" "$HOME/.codex/skills"
publish_managed_skills "$DOTFILES/agents/skills" "$HOME/.claude/skills"
publish_managed_skills "$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"

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
