# Style

This setup is intentionally quieter than the previous desktop customization. The main surface is WezTerm running tmux, with Neovim as the editor and agent CLIs launched from terminal panes.

## Visual Direction

- Terminal: dark, readable, low-glare, with restrained Tokyo Night colors.
- Editor: Neovim uses Tokyo Night and a compact statusline.
- Layout: native macOS windows, Mission Control, Raycast, and Rectangle instead of a custom top bar or tiling manager.
- Typography: JetBrains Mono Nerd Font for terminal/editor glyph support.
- Motion: minimal. Startup should be fast and predictable.

## Terminal

WezTerm is the default terminal. It starts Fish through the `ship` helper, which attaches to the main tmux workspace.

Primary config:

- `wezterm/wezterm.lua`
- `.tmux.conf`
- `fish/config.fish`

## Neovim

Neovim is the main editor. It is organized as a Lua config with Oil for file editing, Telescope for fuzzy navigation, Gitsigns/Diffview for Git, Conform for formatting, LSP for language intelligence, and Copilot for inline suggestions.

Primary config:

- `nvim/init.lua`
- `nvim/lua/ross/options.lua`
- `nvim/lua/ross/keymaps.lua`
- `nvim/lua/ross/plugins/`

## macOS

Use native macOS surfaces instead of replacing them:

- Mission Control for overview.
- Rectangle for simple window moves.
- Raycast for launching and commands.
- Karabiner for keyboard remaps.

The goal is a workflow that still feels like macOS, but with the terminal as the center of gravity.
