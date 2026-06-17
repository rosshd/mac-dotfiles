#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Homebrew packages..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew install fish tmux starship pyenv neovim cmatrix gh
brew install --cask iterm2 raycast docker

echo "==> Setting fish as default shell..."
if ! grep -q /opt/homebrew/bin/fish /etc/shells; then
  echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
fi
chsh -s /opt/homebrew/bin/fish

echo "==> Symlinking configs..."
mkdir -p ~/.config/fish

ln -sf "$DOTFILES/fish/config.fish"   ~/.config/fish/config.fish
ln -sf "$DOTFILES/fish/launch.py"     ~/.config/fish/launch.py
ln -sf "$DOTFILES/fish/spaceship.py"  ~/.config/fish/spaceship.py
ln -sf "$DOTFILES/starship.toml"      ~/.config/starship.toml
ln -sf "$DOTFILES/.tmux.conf"         ~/.tmux.conf

mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
ln -sf "$DOTFILES/iterm2/Ross.json" \
  "$HOME/Library/Application Support/iTerm2/DynamicProfiles/Ross.json"

echo "==> Creating directory structure..."
mkdir -p ~/Developer/{projects,sandbox}
mkdir -p ~/School

echo "==> Suppressing fish greeting..."
fish -c "set -U fish_greeting ''"

echo ""
echo "Done. Open iTerm2, set theme to Minimal (Preferences → Appearance → Theme)."
