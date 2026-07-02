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

### Shell integrations

Wired into `fish/config.fish`:

- **fzf** — fuzzy finder. `Ctrl-T` (files), `Alt-C` (cd into dir).
- **atuin** — sqlite-backed shell history; owns `Ctrl-R` (loaded after fzf so it wins the bind). Run `atuin import auto` once to pull in old history.
- **direnv** — per-directory env loading for project `.envrc` files (pyenv/uv).
- **zoxide** — smart `cd` by frecency.

### tmux persistence

`tpm` manages `tmux-resurrect` + `tmux-continuum` (see `.tmux.conf`). Sessions
auto-save every 15 min and restore on tmux server start, so panes/windows
survive reboots. `prefix + I` reinstalls plugins if needed.

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
~/mac-dotfiles/agents/AGENTS.md
```

`setup.sh` links that file into the supported global instruction path for Codex, Claude, OpenCode, Copilot CLI, and Gemini CLI.
Project `AGENTS.md` files remain the source of project-specific rules.

## Mac Tools

### Raycast

Global launcher and Mac command palette. Keep this as the Mac-level entry point.

### Rectangle

Simple macOS-native window movement and a fallback rather than the primary workspace manager.
Rectangle must be running and have System Settings > Privacy & Security > Accessibility permission before its shortcuts can move windows.
Enable its "Launch on login" setting after the first launch.

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

## Agent Orchestration Stack

These third-party tools are now installed by `setup.sh` and supersede some of
the local helper scripts above. Each adds broad agent integrations or runs a
background process, so understand what it does before relying on it.

| Tool | Replaces | Install source | Notes |
| --- | --- | --- | --- |
| `treehouse` | `wt` | `go install github.com/kunchenguid/treehouse@v1.8.0` | Git worktree orchestrator; symlinked into `~/.local/bin`. |
| `no-mistakes` | `make validate` | `curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh \| sh` | Local git proxy that validates changes through an AI pipeline before push. Runs a daemon (`~/.no-mistakes`, socket + sqlite state). |
| `gnhf` | bounded agent loops | `npm install -g gnhf` | Long-running bounded loop runner. |
| `firstmate` | `crew` | `git clone github.com/kunchenguid/firstmate` | Repo wrapper launched via the `firstmate` script. |
| `lavish-axi` | `plan-artifact` | `npm install -g lavish-axi` | Installs agent hooks + the `lavish` skill via `lavish-axi setup hooks` / `npx skills install lavish`. |

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
| no-mistakes | https://github.com/kunchenguid/no-mistakes |
| gnhf | https://github.com/kunchenguid/gnhf |
| treehouse | https://github.com/kunchenguid/treehouse |
| firstmate | https://github.com/kunchenguid/firstmate |

**OpenSuperWhisper** (dictation; pairs with the `voice-vocab` script and
`~/.config/voice/vocabulary.md`) installs via the Homebrew cask `opensuperwhisper`.
**AXI** is a framework, not a binary: `setup.sh` installs the `kunchenguid/axi`
skill via `npx skills add`, and its per-domain helpers run on demand (e.g.
`npx -y gh-axi`). `lavish-axi` is the installed npm distribution of lavish + AXI.
