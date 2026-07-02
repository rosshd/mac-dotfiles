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
Enable "Launch on login" in Rectangle so the shortcuts remain available after a restart.

The active Rectangle shortcuts use `Control+Option`.
On the K350, that means the physical `Ctrl+Alt` keys and does not include the Windows-logo key.

| Action | macOS keys | Logitech K350 keys |
| --- | --- | --- |
| Left half | `Control+Option+Left` | `Ctrl+Alt+Left` |
| Right half | `Control+Option+Right` | `Ctrl+Alt+Right` |
| Top half | `Control+Option+Up` | `Ctrl+Alt+Up` |
| Bottom half | `Control+Option+Down` | `Ctrl+Alt+Down` |
| Maximize | `Control+Option+Return` | `Ctrl+Alt+Enter` |
| Top left | `Control+Option+U` | `Ctrl+Alt+U` |
| Top right | `Control+Option+I` | `Ctrl+Alt+I` |
| Bottom left | `Control+Option+J` | `Ctrl+Alt+J` |
| Bottom right | `Control+Option+K` | `Ctrl+Alt+K` |
| Restore | `Control+Option+Backspace` | `Ctrl+Alt+Backspace` |

Do not use Caps Lock as Hyper for the half-screen shortcuts.
Hyper adds `Command`, so `Caps Lock+Left/Right` invokes Rectangle's previous/next-display commands instead.

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

Persistence (tpm + resurrect/continuum):

| Action | Key |
| --- | --- |
| Save session | `Ctrl-a Ctrl-s` |
| Restore session | `Ctrl-a Ctrl-r` |
| Install plugins | `Ctrl-a I` |

Sessions also auto-save every 15 min and restore on tmux start, so these are rarely needed by hand.

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
