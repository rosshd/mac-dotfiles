# Reproducibility

This repo now has two rebuild paths.
Use the Homebrew path today.
Use the Nix/Lix path when you want the stronger "new Mac from repo" guarantee.

## Current Path: Brewfile

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

## Next Path: Lix plus nix-darwin

`flake.nix`, `nix/darwin.nix`, and `nix/home.nix` are the starter nix-darwin and home-manager layer.
They mirror the current package set and symlink the same core configs that `setup.sh` links today.
They are intentionally present but not automatically applied.

Install Lix from WezTerm because it needs your sudo password:

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Then activate nix-darwin:

```bash
sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake ~/mac-dotfiles#Rosss-MacBook-Pro
rebuild-mac nix
```

Why this exists:

- It creates the path to fully reproducible macOS settings.
- It lets you move package and config ownership to Nix gradually while using Lix as the Nix-compatible implementation.
- It keeps the current workflow stable while giving future agents a clear destination.

## What Nix Owns First

- Fish, tmux, Starship, Neovim, WezTerm, Karabiner, voice vocabulary, and gh-dash config links.
- Global agent instruction links for Codex, Claude, OpenCode, Copilot CLI, and Gemini CLI.
- Repo-owned helper scripts in `~/.local/bin`.
- The core terminal package set.
- macOS defaults that keep startup clean and predictable.

## What Stays Manual For Now

- Lix installation itself.
- nix-darwin activation.
- Secrets, SSH keys, API keys, and private notification topics.
- Tool-specific sign-ins like GitHub, Tailscale, Codex, Claude, and OpenSuperWhisper permissions.

## Herdr

Herdr is installed through Homebrew and configured from this repo.
It is the terminal-native agent multiplexer for live multi-agent sessions.

Files:

```text
Brewfile
herdr/config.toml
```

The rebuild path installs Herdr and links:

```text
~/.config/herdr/config.toml
```

`setup.sh` also installs Herdr integrations for Codex, Claude, OpenCode, and Copilot CLI.
