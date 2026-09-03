# Ross macOS Dotfiles

This repo stores Ross's keyboard-first macOS development workflow.

## Current Direction

The workflow is terminal-centric and macOS-native:

- WezTerm opens directly into the restored tmux workspace.
- tmux restores the last saved session after reboot; if no snapshot exists, `ship` creates only `home` and `notes`.
- tmux owns task-specific panes, windows, agent side sessions, and the captain status surface on demand.
- Neovim is the primary editor and file navigation surface.
- Codex, Claude Code, and OpenCode are available from the same terminal workflow.
- An agent orchestration stack (`treehouse`, `no-mistakes`, `gnhf`, `firstmate`) layers on top; see [Tools](docs/TOOLS.md).
- Herdr is available as the terminal-native agent multiplexer for long-lived multi-agent sessions.
- The `captain` command is the main control surface for dispatch, status, voice entry, and station notifications.
- Raycast remains the global launcher.
- Rectangle remains the lightweight macOS window helper and the sole login-item exception because Karabiner Hyper window shortcuts depend on it.
- Other login items should stay off; the laptop should boot to a clean desktop with no visible app windows.
- Open WezTerm manually when you want the saved terminal workspace back.
- Karabiner-Elements provides the Caps Lock Hyper key.

## Keyboard Hardware

The primary external keyboard is a Logitech K350 Wave with Windows key legends.

On its default macOS mapping, the Windows-logo key is `Command`, `Alt` is `Option`, and `Ctrl` is `Control`.
Shortcut documentation uses macOS modifier names and includes the K350 labels where they are easy to confuse.

## Start Here

- [Workflow](docs/WORKFLOW.md) - how the full setup works day to day.
- [Keybinds](docs/KEYBINDS.md) - tmux, Neovim, shell, and agent shortcuts.
- [Tools](docs/TOOLS.md) - what each tool is for and when to use it.
- [Reproducibility](docs/REPRODUCIBILITY.md) - Brewfile, active Nix configuration, and rebuild commands.
- [Coding Templates](docs/CODING_TEMPLATES.md) - reusable setup, bug fix, review, validation, worktree, and planning workflows.
- [Remaining Work](docs/REMAINING.md) - what is intentionally deferred or still needs cleanup.

## Bootstrap

Run the installer from the repo root:

```bash
./setup.sh
```

The script installs the current toolchain, links configs into `~/.config`, links local helper scripts into `~/.local/bin`, and applies a small set of native macOS workspace defaults.

The package list lives in `Brewfile`.
Use `rebuild-mac check` to detect package drift and `rebuild-mac brew` to reapply it.
The Lix-backed nix-darwin and Home Manager configuration is active and owns the reproducible system and user configuration.
Use `rebuild-mac nix` to build and activate it.

## Validation

Run the canonical local gate from the repository root before pushing:

```bash
make check
```

The gate runs the shell contract tests, networking unit tests, and Workflow Core catalog audit.
