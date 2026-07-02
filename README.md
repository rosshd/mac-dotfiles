# Ross macOS Dotfiles

This repo stores Ross's keyboard-first macOS development workflow.

## Current Direction

The workflow is terminal-centric and macOS-native:

- WezTerm opens directly into a persistent tmux workspace.
- tmux owns panes, windows, and agent side sessions.
- Neovim is the primary editor and file navigation surface.
- Codex, Claude Code, and OpenCode are available from the same terminal workflow.
- An agent orchestration stack (`treehouse`, `no-mistakes`, `gnhf`, `firstmate`, `lavish-axi`) layers on top; see [Tools](docs/TOOLS.md).
- Raycast remains the global launcher.
- Rectangle remains the lightweight macOS window helper.
- Karabiner-Elements provides the Caps Lock Hyper key.

## Keyboard Hardware

The primary external keyboard is a Logitech K350 Wave with Windows key legends.

On its default macOS mapping, the Windows-logo key is `Command`, `Alt` is `Option`, and `Ctrl` is `Control`.
Shortcut documentation uses macOS modifier names and includes the K350 labels where they are easy to confuse.

## Start Here

- [Workflow](docs/WORKFLOW.md) - how the full setup works day to day.
- [Keybinds](docs/KEYBINDS.md) - tmux, Neovim, shell, and agent shortcuts.
- [Tools](docs/TOOLS.md) - what each tool is for and when to use it.
- [Remaining Work](docs/REMAINING.md) - what is intentionally deferred or still needs cleanup.

## Bootstrap

Run the installer from the repo root:

```bash
./setup.sh
```

The script installs the current toolchain, links configs into `~/.config`, links local helper scripts into `~/.local/bin`, and applies a small set of native macOS workspace defaults.
