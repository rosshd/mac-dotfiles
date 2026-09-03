# Tools

## Core terminal tools

### WezTerm

WezTerm is the terminal emulator.
It opens Fish and the `ship` tmux workspace.

Config:

```text
~/.config/wezterm/wezterm.lua
```

### tmux

tmux owns persistent panes, windows, sessions, and direct agent side panes.
The default `ship` session starts with `home` and `notes`.

Config:

```text
~/.tmux.conf
```

### Neovim

Neovim is the primary editor and file-navigation tool.

Config:

```text
~/.config/nvim/
```

### Fish and Starship

Fish sets PATH, pyenv, shell integrations, editor defaults, and aliases.
Starship supplies the compact prompt.

```text
~/.config/fish/config.fish
~/.config/starship.toml
```

### Shell integrations

- fzf provides file and directory fuzzy search.
- atuin owns searchable shell history.
- direnv loads repository environment files.
- zoxide provides frecency-based directory changes.

### Session persistence

`tpm` manages `tmux-resurrect` and `tmux-continuum`.
Sessions save every five minutes and restore when a new tmux server starts.
WezTerm remains a manual launch so login starts with a clean desktop.

## Software factory tools

### GitHub Issues and pull requests

GitHub Issues are the durable work briefs.
Pull requests hold the branch diff, review evidence, CI, risk, rollback, and remaining release checks.

```bash
gh issue list
gh issue view <number>
gh pr list
gh pr checks <number>
```

### Codex

Codex is the default implementation and repository tool.
One issue maps to one Codex owner task and one managed worktree.

```bash
codex
agent codex
cdx
```

Workflow Core supplies planning, implementation, review, shipping, repository bootstrap, and dispatch skills.
Its source lives at `plugins/workflow-core` and the personal Codex marketplace installs it.

```bash
codex plugin list
```

### Claude Code and OpenCode

Claude Code and OpenCode remain available as direct alternate agent clients.
Use separate ownership boundaries before two clients can write to the same repository.

```bash
claude
agent claude
cc
opencode
agent opencode
oc
```

### gh-dash

`gh dash` is the terminal dashboard for pull requests and issues.
The config is linked from `gh-dash/config.yml`.

### Repository gates

Each repository owns one canonical pre-push gate.
This repository uses:

```bash
make check
```

Run one bounded `codex review --base <base>` after the gate passes on the scoped commit.
Required CI must cover the same exact head before merge.

## Rebuild and health

### rebuild-mac

`rebuild-mac` connects package and Nix state to this repository.

```bash
rebuild-mac check
rebuild-mac brew
rebuild-mac nix
```

Use `check` for read-only package and flake readiness.
Use an applying command only when the current task authorizes it.

### doctor

`doctor` checks the retained command line tools, configs, agent guidance, Workflow Core skills, plugin state, session persistence, clean-boot defaults, and phone access.
`agent-doctor` checks agent discovery, skill drift, networking integration, PATH duplication, cache size, and repository health.

## Agent guidance

All supported agent clients share:

```text
~/agents/AGENTS.md
```

`~/agents` points to the version-controlled `~/mac-dotfiles/agents` source.
Project-specific `AGENTS.md` files stay inside their repositories.

## Local workflow scripts

These scripts are linked into `~/.local/bin`.

| Script | Purpose |
| --- | --- |
| `ship` | Create or attach the main tmux workspace. |
| `agent` | Launch Codex, Claude Code, or OpenCode directly. |
| `agent-doctor` | Audit agent discovery and related local health. |
| `doctor` | Validate the retained workstation toolchain. |
| `rebuild-mac` | Check or apply the Brewfile and Nix configuration. |
| `notify` | Send a generic macOS and optional phone notification. |
| `networking` | Operate the private networking workspace. |
| `networking-mcp` | Expose read-only networking retrieval. |
| `voice-vocab` | Print the voice transcription vocabulary. |
| `plan-artifact` | Open the local planning artifact workflow. |
| `clean-reboot` | Reapply no-restore defaults and reboot. |

## Private networking

`networking` captures notes, imports bounded Apple Calendar context, searches profiles, and files pending notes through the global networking skill.
`people` is its Fish alias.

```bash
networking capture --source dictated -- "Met Ada at..."
networking calendar --days-back 1 --days-forward 14
networking process
networking due
```

Raycast sends dictated or pasted notes to the same private inbox.

## macOS tools

Raycast is the global launcher.
Rectangle provides simple native window movement and stays enabled at login because the Hyper shortcuts depend on it.
Karabiner-Elements maps held Caps Lock to Hyper and tapped Caps Lock to Escape.
OpenSuperWhisper supplies local dictation.
Tailscale plus macOS Remote Login provides private phone access.

## Notifications

The Codex Stop hook sends one generic completion notification through `notify`.
The tmux `Ctrl-a N` binding runs a generic notification smoke test.

```bash
notify "Review ready" "The task finished"
```

Private server and topic values remain outside this repository.

## Sources

| Tool | URL |
| --- | --- |
| WezTerm | https://wezterm.org |
| tmux | https://github.com/tmux/tmux/wiki |
| Neovim | https://neovim.io |
| Codex | https://developers.openai.com/codex |
| GitHub CLI | https://cli.github.com |
| gh-dash | https://github.com/dlvhdr/gh-dash |
| Nix | https://nixos.org |
| nix-darwin | https://github.com/LnL7/nix-darwin |
| Home Manager | https://github.com/nix-community/home-manager |
