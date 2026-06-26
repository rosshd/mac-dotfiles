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
brew install \
  fish tmux starship pyenv neovim fd fzf ripgrep eza bat git-delta lazygit gh go node jq \
  lua-language-server stylua pyright ruff zoxide uv wget tree fastfetch atuin direnv \
  anomalyco/tap/opencode

brew install --cask \
  wezterm raycast rectangle karabiner-elements font-jetbrains-mono-nerd-font \
  claude-code codex opensuperwhisper

# --- Agent orchestration stack -------------------------------------------------
# These replace the local helper scripts noted in docs/TOOLS.md:
#   treehouse -> wt, no-mistakes -> make validate, gnhf -> bounded loops,
#   firstmate -> crew, lavish -> plan-artifact.
echo "Installing agent orchestration stack..."

# treehouse: Git worktree orchestrator (Go module -> ~/go/bin).
go install github.com/kunchenguid/treehouse@v1.8.0
ln -sfn "$(go env GOPATH)/bin/treehouse" "$HOME/.local/bin/treehouse"

# gnhf + lavish-axi: published npm packages, installed globally.
npm install -g gnhf@0.1.41 lavish-axi@0.1.31

# lavish-axi: install agent hooks (Claude Code, Codex, OpenCode).
lavish-axi setup hooks

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
# and starts a daemon. Re-inspect docs/install.sh before trusting a new version.
if ! command -v no-mistakes >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
fi
# ------------------------------------------------------------------------------

mkdir -p \
  "$HOME/.config/fish" \
  "$HOME/.config" \
  "$HOME/.config/wezterm" \
  "$HOME/.config/nvim" \
  "$HOME/.config/voice" \
  "$HOME/.local/bin" \
  "$HOME/.codex" \
  "$HOME/.claude" \
  "$HOME/.config/opencode"

ln -sfn "$DOTFILES/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sfn "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DOTFILES/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"
ln -sfn "$DOTFILES/voice/vocabulary.md" "$HOME/.config/voice/vocabulary.md"

for script in ship agent wt crew plan-artifact voice-vocab doctor firstmate; do
  ln -sfn "$DOTFILES/bin/$script" "$HOME/.local/bin/$script"
  chmod +x "$DOTFILES/bin/$script"
done

ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$DOTFILES/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
# Opinions/voice files that AGENTS.md defers to, kept lean for token efficiency.
ln -sfn "$DOTFILES/STYLE.md" "$HOME/STYLE.md"
ln -sfn "$DOTFILES/agents/VOICE.md" "$HOME/VOICE.md"
ln -sfn "$DOTFILES/agents/skills" "$HOME/.codex/skills"
ln -sfn "$DOTFILES/agents/skills" "$HOME/.claude/skills"
ln -sfn "$DOTFILES/agents/skills" "$HOME/.config/opencode/skills"

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

# Keep screenshots in a stable folder.
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

echo "Setup complete. Restart the Dock or log out/in for macOS defaults to fully apply."
echo "Run 'doctor' to validate the toolchain."
echo "Open WezTerm; it will start the 'ship' tmux workspace."
