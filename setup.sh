#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Homebrew packages..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar || true
brew install fish tmux starship pyenv neovim cmatrix gh sketchybar
brew install --cask iterm2 raycast docker font-sketchybar-app-font nikitabobko/tap/aerospace

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

mkdir -p ~/.config/sketchybar ~/.config/aerospace
ln -sf "$DOTFILES/sketchybar/sketchybarrc" ~/.config/sketchybar/sketchybarrc
ln -sfn "$DOTFILES/sketchybar/plugins"     ~/.config/sketchybar/plugins
ln -sf "$DOTFILES/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml

mkdir -p ~/.vscode/extensions
rm -rf ~/.vscode/extensions/ross-local.candiru-space-theme-0.1.0
cp -R "$DOTFILES/vscode/candiru-space-theme" ~/.vscode/extensions/ross-local.candiru-space-theme-0.1.0

mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
ln -sf "$DOTFILES/iterm2/Ross.json" \
  "$HOME/Library/Application Support/iTerm2/DynamicProfiles/Ross.json"


echo "==> Applying desktop polish..."
mkdir -p "$HOME/Pictures/Screenshots"
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string png
brew services start sketchybar || true
open -ga AeroSpace || true

echo "==> Creating directory structure..."
mkdir -p ~/Developer/{projects,sandbox}
mkdir -p ~/School

echo "==> Suppressing fish greeting..."
fish -c "set -U fish_greeting ''"

echo ""
echo "Done. Open iTerm2, set theme to Minimal (Preferences → Appearance → Theme)."
