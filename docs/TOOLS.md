# Tools

## Core Tools

### WezTerm

Terminal emulator. It should stay visually quiet and open directly into `ship`.

Config:

```text
~/.config/wezterm/wezterm.lua
```

### tmux

Persistent workspace layer for panes, windows, sessions, and agent side panes.
The default `ship` session starts with only `home` and `notes`; task-specific windows are opened on demand.

Config:

```text
~/.tmux.conf
```

### Neovim

Primary editor and file navigation surface.

Config:

```text
~/.config/nvim/
```

Important modules:

```text
~/.config/nvim/init.lua
~/.config/nvim/lua/ross/options.lua
~/.config/nvim/lua/ross/keymaps.lua
~/.config/nvim/lua/ross/lazy.lua
~/.config/nvim/lua/ross/lsp.lua
```

### Fish

Interactive shell. It sets PATH, pyenv paths, Starship, Zoxide, editor defaults, and aliases.

Config:

```text
~/.config/fish/config.fish
```

### Starship

Prompt. Keep it compact enough that tmux panes stay readable.

Config:

```text
~/.config/starship.toml
```

### Rebuild Mac

`rebuild-mac` is the laptop rebuild helper.
It keeps package installs tied to the repo instead of scattered across one-off commands.

```bash
rebuild-mac check   # check Brewfile and Nix readiness
rebuild-mac brew    # apply Brewfile
rebuild-mac nix     # apply nix-darwin after Nix is installed
```

The Fish alias is `rebuild`.

### Herdr

Terminal-native multiplexer for agent-heavy work.
Use it when the job is less about one tmux workspace and more about watching several live agents, panes, and attention states at once.
Herdr runs in the terminal, keeps real PTYs alive, tracks agent state, and supports remote/phone-sized attach flows.

Config:

```text
~/.config/herdr/config.toml
```

Current integrations:

```bash
herdr integration status
```

Installed integrations:

- Codex
- Claude Code
- OpenCode
- GitHub Copilot CLI

Common commands:

```bash
herdr                    # launch or attach to the default persistent session
herdr --session captain  # named session
herdr status server      # check whether the server is running
herdr server stop        # stop Herdr server
herdr integration status # check agent hooks/plugins
```

Use `herd` as the Fish alias.
Keep Glass/ntfy notifications in `notify`; Herdr uses in-app toasts and no sound so alerts do not stack.

### Shell integrations

Wired into `fish/config.fish`:

- **fzf** - fuzzy finder. `Ctrl-T` (files), `Alt-C` (cd into dir).
- **atuin** - sqlite-backed shell history; owns `Ctrl-R` (loaded after fzf so it wins the bind). Run `atuin import auto` once to pull in old history.
- **direnv** - per-directory env loading for project `.envrc` files (pyenv/uv).
- **zoxide** - smart `cd` by frecency.

### tmux persistence

`tpm` manages `tmux-resurrect` + `tmux-continuum` (see `.tmux.conf`).
Sessions auto-save and restore when a new tmux server starts.
WezTerm itself is not a login item, so reboot still starts with a clean desktop until you intentionally open the terminal.
Use `prefix + Ctrl-r` when you want to manually restore a different previous workspace.
`prefix + I` reinstalls plugins if needed.

## Agent CLIs

### Codex CLI

OpenAI coding agent. Use for local repo implementation, review, validation, and tool-heavy work.

```bash
codex
agent codex
cdx
```

### Claude Code

Anthropic coding agent. Use as an alternate harness for broad reasoning and implementation.

```bash
claude
agent claude
cc
```

### OpenCode

Model-agnostic TUI agent.

```bash
opencode
agent opencode
oc
```

Agent CLIs share one canonical global guidance file:

```text
~/agents/AGENTS.md
```

`~/agents` is an editable link to the version-controlled `~/mac-dotfiles/agents` source.
`setup.sh` links its guidance into the supported global instruction path for Codex, Claude, OpenCode, Copilot CLI, and Gemini CLI.
Project `AGENTS.md` files remain the source of project-specific rules.

### Private networking

`networking` captures dictated notes, imports bounded Apple Calendar context into a private inbox, searches profiles, and launches Codex to file pending notes with the global networking skill.
`people` is its Fish alias.

```bash
networking capture --source dictated -- "Met Ada at..."
networking calendar --days-back 1 --days-forward 14
networking process
networking due
```

Raycast's `Capture Networking Note` command sends dictated or pasted text to the same inbox.
`networking-mcp` exposes read-only profile, relationship, interaction, and follow-up retrieval.
`agent-doctor` checks agent discovery paths, divergent skill copies, networking integration, MCP registration, PATH duplication, cache budget, and dirty repositories.

## Mac Tools

### Raycast

Global launcher and Mac command palette. Keep this as the Mac-level entry point.

### Rectangle

Simple macOS-native window movement and a fallback rather than the primary workspace manager.
Rectangle must be running and have System Settings > Privacy & Security > Accessibility permission before its shortcuts can move windows.
Keep its "Launch on login" setting enabled so Hyper window shortcuts work immediately after startup.
This is compatible with clean startup because Rectangle is a quiet background utility, not a restored work session.

See [Keybinds](KEYBINDS.md#rectangle) for the recommended shortcuts and Logitech K350 key labels.

### Karabiner-Elements

Keyboard remapping. Current important rule:

- Caps Lock held -> Hyper (`Ctrl+Option+Command`)
- Caps Lock tapped -> Escape

### OpenSuperWhisper

Local Whisper dictation/transcription app (cask `opensuperwhisper`). Feed it the
prompt from `voice-vocab` / `~/.config/voice/vocabulary.md` so it spells
workflow-specific terms correctly. Requires arm64 + macOS 14+.

## Git Tools

### Git Delta

Terminal diff viewer. Git is configured globally to use `delta` as the pager with side-by-side diffs.

### Lazygit

Fast terminal Git UI. Use from Neovim with `Space gl` or directly with `lazygit`.

### gh-dash

Terminal dashboard for GitHub PRs and issues (`gh` extension, run with `gh dash`).
Sections are scoped to Ross's repos in `gh-dash/config.yml`, symlinked to `~/.config/gh-dash/config.yml` by `setup.sh`.

## Local Workflow Scripts

These live in:

```text
~/.local/bin
```

| Script | Purpose |
| --- | --- |
| `ship` | Create/attach main tmux workspace. |
| `agent` | Unified launcher for Codex, Claude, OpenCode. |
| `wt` | Native Git worktree helper. |
| `crew` | Local first-mate-lite orchestration helper. |
| `plan-artifact` | Generate local HTML planning artifacts. |
| `voice-vocab` | Print transcription vocabulary prompt. |
| `firstmate` | Cd into the firstmate repo and launch its agent. |
| `doctor` | Validate the toolchain (binaries, configs, versions). |
| `rebuild-mac` | Check or apply the Brewfile and active nix-darwin rebuild path. |
| `clean-reboot` | Reapply no-restore defaults, flush preferences, and reboot with `shutdown -r now`. |

See [Coding Templates](CODING_TEMPLATES.md) for which tool owns each part of the coding workflow and why.

## Agent Orchestration Stack

These third-party tools are now installed by `setup.sh` and supersede some of
the local helper scripts above. Each adds broad agent integrations or runs a
background process, so understand what it does before relying on it.

| Tool | Replaces | Install source | Notes |
| --- | --- | --- | --- |
| `treehouse` | `wt` | `treehouse update` / `go install github.com/kunchenguid/treehouse@v2.0.0` | Git worktree pool orchestrator; `fleet` leases worktrees from it by default. |
| `no-mistakes` | `make validate` | `./setup.sh` pins v1.37.0 and verifies the release archive SHA-256 before extraction. | Local git proxy that validates changes through an AI pipeline before push. Runs a daemon (`~/.no-mistakes`, socket + sqlite state). |
| `gnhf` | bounded agent loops | `npm install -g gnhf` | Long-running bounded loop runner. |
| `herdr` | scattered agent panes | `brew install herdr` | Agent-aware terminal multiplexer; use for live multi-agent visibility, remote attach, and phone-sized terminal sessions. |
| `firstmate` | `crew` | `git clone github.com/kunchenguid/firstmate` | Repo wrapper launched via the `firstmate` script. |
| `lavish-axi` | `plan-artifact` | `npm install -g lavish-axi` | Installs agent hooks via `lavish-axi setup hooks`; the repo vendors the shared `lavish` skill. |

`~/.no-mistakes/config.yaml` is linked from `no-mistakes/config.yaml`.
It pins the Codex, Claude, and OpenCode binary paths so no-mistakes still finds agents when launched from git hooks, daemons, or iPhone SSH commands with a reduced PATH.
Install no-mistakes by running `./setup.sh` from this repository instead of executing an upstream installer directly.
The setup path selects the pinned Darwin archive for the current architecture, verifies its repository-reviewed SHA-256, installs the binary, and restarts the daemon.

Validate everything at once with `doctor`.

## Sources

Canonical upstreams for every tool in this workflow.

| Tool | URL |
| --- | --- |
| WezTerm | https://wezterm.org |
| tmux | https://github.com/tmux/tmux/wiki |
| Neovim | https://neovim.io |
| npx skills CLI | https://github.com/vercel-labs/skills |
| OpenSuperWhisper | https://github.com/starmel/OpenSuperWhisper |
| AXI | https://axi.md |
| lavish | https://github.com/kunchenguid/lavish |
| Herdr | https://herdr.dev |
| no-mistakes | https://github.com/kunchenguid/no-mistakes |
| gnhf | https://github.com/kunchenguid/gnhf |
| treehouse | https://github.com/kunchenguid/treehouse |
| firstmate | https://github.com/kunchenguid/firstmate |
| Nix | https://nixos.org |
| nix-darwin | https://github.com/LnL7/nix-darwin |
| home-manager | https://github.com/nix-community/home-manager |

**OpenSuperWhisper** (dictation; pairs with the `voice-vocab` script and
`~/.config/voice/vocabulary.md`) installs via the Homebrew cask `opensuperwhisper`.
**AXI** is a framework, not a binary.
The repo vendors its shared skill under `agents/skills/axi`, and per-domain helpers run on demand (for example, `npx -y gh-axi`).
`lavish-axi` is the installed npm distribution of lavish + AXI.
