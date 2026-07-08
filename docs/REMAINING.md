# Remaining Work

## Done

- Health check script (`bin/doctor`): verifies binaries, Fish/tmux/Neovim/WezTerm
  configs, tool versions, and warns on legacy background processes.
- Installed the external orchestration stack and wired it into `setup.sh`:
  `treehouse`, `no-mistakes` (real installer command), `gnhf`, `firstmate`,
  `lavish-axi`, `opensuperwhisper`. See [Tools](TOOLS.md) for what each replaces.
- Made the repo the single source of truth: all configs and agent files are symlinked into place.
  Codex, Claude, OpenCode, Copilot CLI, and Gemini CLI global instruction paths point at the same `agents/AGENTS.md`.
- Shell efficiency: fzf keybindings, atuin history, direnv, and tmux session
  persistence (tpm + resurrect + continuum).
- Simplified the default `ship` workspace to `home` and `notes` only.
- Added reusable coding templates with tool ownership and rationale.
- Committed the legacy-to-terminal-first migration and pushed the branch.
- Added `Brewfile` as the canonical package manifest and changed `setup.sh` to use it.
- Added `rebuild-mac` for package drift checks, Brewfile application, and future nix-darwin rebuilds.
- Added starter Nix, nix-darwin, and home-manager config in `flake.nix` and `nix/`.
- Added `doctor` checks for Brewfile drift, Nix readiness, Herdr integration status, and phone host visibility.
- Added `captain phone-host` for stable iPhone Shortcut SSH setup.
- Installed and configured Herdr as the live terminal agent multiplexer.
- Installed Herdr integrations for Codex, Claude, OpenCode, and Copilot CLI.

## Manual steps (need your password / one-time)

- Set fish as the login shell:
  `echo "$(command -v fish)" | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"`
- Import existing shell history into atuin: `atuin import auto`
- Install Lix when you want to move from the Brewfile path to the full nix-darwin path.
- Bootstrap nix-darwin with `sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake ~/mac-dotfiles#Rosss-MacBook-Pro`.

## Medium Priority

1. Disable all non-essential macOS Login Items and per-app "launch on login" settings.

   Check at System Settings > General > Login Items and in each app that can self-register.
   Keep Rectangle and Karabiner available at startup because Caps Lock Hyper window shortcuts depend on them.
   Priority apps to inspect: WezTerm, Raycast, OpenSuperWhisper, Aerial, no-mistakes, and any menu bar utility.


## Low Priority

2. Decide whether VS Code needs any dotfiles at all or stays outside this workflow.
