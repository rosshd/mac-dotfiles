# Reproducibility

This repo has two rebuild paths.
The active Nix/Lix path owns the reproducible system and user configuration.
The Homebrew path remains available for package-only recovery and is also applied by nix-darwin activation.

## Package manifest: Brewfile

`Brewfile` is the canonical package manifest for the current setup.
It owns the terminal tools, agent CLIs, Mac apps, fonts, and quiet background utilities used by the workflow.

Commands:

```bash
rebuild-mac brew
rebuild-mac check
doctor
```

Why this exists:

- It removes package drift from `setup.sh`.
- It gives `doctor` a concrete way to detect missing apps.
- It makes a fresh Mac bootstrap less dependent on memory.

## Active path: Lix plus nix-darwin

`flake.nix`, `nix/darwin.nix`, and `nix/home.nix` define the active nix-darwin and Home Manager layer.
They own the package set, macOS defaults, and repo-managed configuration links.

Install Lix from WezTerm because it needs your sudo password:

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Bootstrap nix-darwin on a new Mac, then use the normal rebuild command:

```bash
sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake ~/mac-dotfiles#Rosss-MacBook-Pro
rebuild-mac nix
```

The installed `~/.local/bin/rebuild-mac` symlink resolves back to this repo before selecting the flake, so the normal command works outside the repo directory.

Why this exists:

- It provides reproducible macOS settings and user configuration.
- It keeps package and config ownership explicit while using Lix as the Nix-compatible implementation.
- It gives future agents one active rebuild path instead of an unfinished migration target.

## What Nix owns first

- Fish, tmux, Starship, Neovim, WezTerm, Karabiner, voice vocabulary, and gh-dash config links.
- Global agent instruction links for Codex, Claude, OpenCode, Copilot CLI, and Gemini CLI.
- Repo-owned helper scripts in `~/.local/bin`.
- The core terminal package set.
- macOS defaults that keep startup clean and predictable.

## What stays manual for now

- Initial Lix and nix-darwin bootstrap on a new Mac.
- Secrets, SSH keys, API keys, and private notification topics.
- Tool-specific sign-ins like GitHub, Tailscale, Codex, Claude, and OpenSuperWhisper permissions.

## Workflow Core

The canonical plugin source lives under `plugins/workflow-core`.
The personal Codex marketplace points at that source, and `codex plugin list` reports whether the plugin is installed and enabled.
`doctor` checks the source skills and installed plugin state.

## Check-mode rebuild

Run this before any authorized package or Nix application:

```bash
rebuild-mac check
```

The command runs `brew bundle check` and parses the Nix flake without changing the installed generation.
The repository contract tests also prove that retired packages, links, hooks, aliases, and helper entry points are absent from a clean rebuild source.
