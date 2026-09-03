# Keybinds

## macOS Layer

Keep macOS simple and mostly native.
The primary external keyboard is a Logitech K350 Wave with Windows key legends.

- Raycast: global command launcher.
- Rectangle: keyboard window snapping when needed.
- Karabiner-Elements: Caps Lock is Hyper when held, Escape when tapped.

K350 modifier labels:

| macOS modifier | K350 key label |
| --- | --- |
| `Command` | Windows-logo key |
| `Option` | `Alt` |
| `Control` | `Ctrl` |

Hyper means:

```text
Ctrl + Option + Command
```

### Rectangle

Rectangle must be running and enabled in System Settings > Privacy & Security > Accessibility.
Keep "Launch on login" enabled so Caps Lock window shortcuts work immediately after startup.
Rectangle is allowed as a quiet background utility; clean startup means no restored workspaces, not no keyboard helpers.

The active Rectangle shortcuts use Hyper: `Control+Option+Command`.
On the K350, hold Caps Lock to emit Hyper through Karabiner-Elements.
You can also use the physical `Ctrl+Alt+Windows-logo` keys.

| Action | macOS keys | Logitech K350 keys |
| --- | --- | --- |
| Almost maximize | `Hyper+Z` | `Caps Lock+Z` |
| Left half | `Hyper+Left` | `Caps Lock+Left` |
| Right half | `Hyper+Right` | `Caps Lock+Right` |
| Top half | `Hyper+Up` | `Caps Lock+Up` |
| Bottom half | `Hyper+Down` | `Caps Lock+Down` |
| Maximize | `Hyper+F` | `Caps Lock+F` |
| Center | `Hyper+C` | `Caps Lock+C` |

Open Rectangle Settings > Shortcuts to inspect or change the active bindings.

If every shortcut does nothing:

1. Confirm the Rectangle icon is present in the menu bar.
2. Confirm Rectangle is enabled under macOS Accessibility permissions.
3. Confirm "Launch on login" is enabled in Rectangle Settings > General.
4. Confirm the shortcut shown in Rectangle Settings > Shortcuts.
5. Check that the foreground app is not in Rectangle's ignored-app list.

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
Fresh WezTerm windows open large and centered, matching the intent of Rectangle's `Almost maximize` action without needing Rectangle at login.

## Shell (Fish)

History and fuzzy search:

| Action | Key |
| --- | --- |
| Search shell history (atuin) | `Ctrl+r` |
| Fuzzy-find files (fzf) | `Ctrl+t` |
| Fuzzy-cd into directory (fzf) | `Alt+c` |

atuin owns `Ctrl+r`; it loads after fzf so it wins that binding.

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

Captain workflow:

| Action | Key |
| --- | --- |
| Captain status popup | `Ctrl-a C` |
| Captain watch popup | `Ctrl-a F` |
| Voice prompt popup | `Ctrl-a V` |
| Fleet brief popup | `Ctrl-a B` |
| Test station notification | `Ctrl-a N` |

Persistence (tpm + resurrect/continuum):

| Action | Key |
| --- | --- |
| Save session | `Ctrl-a Ctrl-s` |
| Restore session | `Ctrl-a Ctrl-r` |
| Install plugins | `Ctrl-a I` |

Sessions auto-save every 5 min and restore when a new tmux server starts.
Run `ship --save` before a manual restart when you want the current pane layout captured immediately.
WezTerm itself still stays manual so login starts clean.

## Herdr

Prefix:

```text
Ctrl-b
```

Core Herdr bindings:

| Action | Key |
| --- | --- |
| Help | `Ctrl-b ?` |
| Detach | `Ctrl-b q` |
| Workspace picker | `Ctrl-b w` |
| Goto picker | `Ctrl-b g` |
| New tab | `Ctrl-b c` or `Ctrl+Alt+c` |
| Previous / next tab | `Ctrl-b p` / `Ctrl-b n` |
| Split right | `Ctrl-b v` or `Ctrl+Alt+d` |
| Split down | `Ctrl-b -` or `Ctrl+Alt+Shift+d` |
| Focus pane | `Ctrl-b h/j/k/l` or `Ctrl+Alt+h/j/k/l` |
| Zoom pane | `Ctrl-b z` or `Ctrl+Alt+z` |
| Toggle sidebar | `Ctrl-b b` |
| Focus agent 1-9 | `Ctrl-b Alt+1..9` |

Herdr is mouse-native too, but these bindings keep it usable from the keyboard.
Use Herdr when you want a live agent dashboard; use tmux for the default workspace.

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
| `herd` | `herdr` |
| `captain` | captain command deck |
| `deck` | `captain status` |
| `cr` | `clean-reboot` |
| `rebuild` | `rebuild-mac` |
| `worktrees` | `wt list` |
| `vocab` | `voice-vocab` |
| `plan` | `plan-artifact` |
