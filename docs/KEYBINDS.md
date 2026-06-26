# Keybinds

## macOS Layer

Keep macOS simple and mostly native.

- Raycast: global command launcher.
- Rectangle: keyboard window snapping when needed.
- Karabiner-Elements: Caps Lock is Hyper when held, Caps Lock when tapped.

Hyper means:

```text
Ctrl + Option + Command
```

## WezTerm

WezTerm opens Fish and runs `ship`.

Configured keys:

| Action | Key |
| --- | --- |
| Toggle fullscreen | `Cmd+Enter` |
| New WezTerm tab | `Cmd+t` |
| Close WezTerm tab | `Cmd+w` |
| Move word left | `Option+Left` |
| Move word right | `Option+Right` |

Most workspace navigation should happen in tmux, not WezTerm tabs.

## tmux

Prefix:

```text
Ctrl-a
```

Panes:

| Action | Key |
| --- | --- |
| Split horizontal | `Ctrl+\` |
| Split vertical | `Ctrl+g` |
| Focus left/down/up/right | `Ctrl+h/j/k/l` |
| Kill pane | `Ctrl+x` |
| Resize pane | `Ctrl-a H/J/K/L` |

Windows:

| Action | Key |
| --- | --- |
| New window | `Ctrl+t` |
| Next window | `Ctrl+n` |
| Previous window | `Ctrl+p` |
| Choose session | `Ctrl-a S` |
| Kill window | `Ctrl-a X` |
| Reload tmux config | `Ctrl-a r` |

Agent panes:

| Action | Key |
| --- | --- |
| Open Codex side pane | `Ctrl+y` |
| Open Claude side pane | `Ctrl+o` |
| Open OpenCode side pane | `Ctrl-a o` |

## Neovim

Leader:

```text
Space
```

Navigation:

| Action | Key |
| --- | --- |
| Edit files with Oil | `-` or `Space e` |
| Find files | `Space ff` |
| Grep text | `Space fg` |
| Recent files | `Space fr` |
| Move split left/down/up/right | `Ctrl+h/j/k/l` |
| Save | `Space w` |
| Quit | `Space q` |
| Clear search highlight | `Space h` |
| Close buffer | `Space x` |
| Terminal split | `Space tt` |

Git:

| Action | Key |
| --- | --- |
| Working tree diff | `Space gd` |
| Staged diff | `Space gD` |
| File history | `Space gh` |
| Repo history | `Space gH` |
| Close Diffview | `Space gq` |
| Lazygit tab | `Space gl` |
| Next hunk | `]h` |
| Previous hunk | `[h` |
| Preview hunk | `Space gp` |
| Stage hunk | `Space gs` |
| Reset hunk | `Space gr` |

LSP:

| Action | Key |
| --- | --- |
| Go to definition | `gd` |
| References | `gr` |
| Hover | `K` |
| Rename | `Space rn` |
| Code action | `Space ca` |
| Line diagnostics | `Space ld` |
| Format | `Space lf` |
| Previous diagnostic | `[d` |
| Next diagnostic | `]d` |

Copilot:

| Action | Key |
| --- | --- |
| Authenticate once | `:Copilot auth` |
| Accept suggestion | `Ctrl+j` |
| Next suggestion | `Alt+]` |
| Previous suggestion | `Alt+[` |
| Dismiss suggestion | `Ctrl+]` |

## Fish Aliases

| Alias | Command |
| --- | --- |
| `dev` | `cd ~/Developer/projects` |
| `school` | `cd ~/School` |
| `sandbox` | `cd ~/Developer/sandbox` |
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | recent graph log |
| `gd` | `git diff` |
| `ll` | `eza -lah --git --group-directories-first` |
| `la` | `eza -la --git --group-directories-first` |
| `cat` | `bat` |
| `vi` | `nvim` |
| `main` | `ship` |
| `a` / `agents` | `agent` |
| `cdx` | `codex` |
| `cc` | `claude` |
| `oc` | `opencode` |
| `worktrees` | `wt list` |
| `vocab` | `voice-vocab` |
| `plan` | `plan-artifact` |
| `captain` | `crew` |
