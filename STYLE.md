# Candiru Style Guide

This is the source of truth for Ross's terminal/editor look. The guiding idea is one visual family with two clear roles: iTerm2 is the warm amber command center, and VS Code is the cool blue editor canvas.

## Best Overall Split

| Area | Color role | Hex |
| --- | --- | --- |
| iTerm active accent | Warm amber | `#F5A524` |
| iTerm stronger highlight | Gold | `#FFB454` |
| VS Code active accent | Soft blue | `#7AA2F7` |
| VS Code secondary accent | Cyan | `#7DCFFF` |
| Shared background | Midnight navy | `#0B1020` |
| Editor/terminal surface | Dark navy | `#111827` |
| Muted border | Slate blue | `#2F354D` |
| Text | Soft lavender-white | `#C0CAF5` |
| Muted text/icons | Gray-blue | `#565F89` |

## Core Palette

| Role | Hex | Source | Notes |
| --- | --- | --- | --- |
| iTerm background | `#111827` | Target style | Slightly more solid terminal surface for long sessions. |
| Shared midnight navy | `#0B1020` | Target style | App chrome, title/status bars, shared dark base. |
| Legacy iTerm navy | `#0A0F24` | iTerm current `Background Color` | Existing terminal background; keep as reference when matching old screenshots. |
| Deep navy | `#080C1C` | Derived | Secondary panels/tabs when a little depth is needed. |
| Foreground text | `#C0CAF5` | Target style | Main readable foreground for VS Code and optional terminal tuning. |
| Terminal cream | `#D6DEEB` | Target style | Good iTerm text color if keeping terminal warmer. |
| Muted text | `#565F89` | Target style | Inactive icons, muted labels, low-priority UI. |
| iTerm amber | `#F5A524` | Target style | Prompt, cursor, tmux active accents. |
| iTerm gold | `#FFB454` | Target style | Strong terminal highlights. |
| iTerm border amber | `#C4892F` | Target style | Pane borders and subtle terminal structure. |
| VS Code blue | `#7AA2F7` | Target style | Primary editor accent, active borders, activity/status accents. |
| VS Code cyan | `#7DCFFF` | Target style | Secondary highlights, status foreground, hover/focus accents. |
| Muted structure | `#2F354D` | Target style | VS Code inactive borders/dividers. |
| Green | `#A6E08C` | Terminal ANSI | Success/strings. |
| Red orange | `#FF7240` | Terminal ANSI | Errors/deletions. |

## App Roles

### iTerm2: Amber Glass Command Center

- Keep iTerm/tmux warm and amber-accented.
- Primary accent: `#F5A524`.
- Strong highlight: `#FFB454`.
- Border/accent structure: `#C4892F`.
- Background target: `#111827` or current legacy `#0A0F24` if preserving the existing look.
- Text target: `#D6DEEB`; muted text: `#7C859C`.
- Selection target: `#26324A`.
- Transparency should be visible but not distracting: opacity around `88-92%`.
- Blur target: `25-35`.
- The terminal should read as the focused command cockpit.

### VS Code: Cool Blue Editor Canvas

- Keep the same dark navy family so it belongs with iTerm.
- Pull from the blue/cyan part of the wallpaper, not the orange/gold clouds.
- Primary accent: `#7AA2F7`.
- Secondary accent: `#7DCFFF`.
- Muted structure: `#2F354D`.
- Background/chrome: `#0B1020`.
- Editor surface: `#111827`.
- Text: `#C0CAF5`; muted text/icons: `#565F89`.
- VS Code should be less transparent and more structured than iTerm for readability; target `96%` opacity.
- Reserve orange for warnings, Git status, and rare attention states, not normal editor borders.
- Do not use orange borders in VS Code; they make it blend into iTerm.

## Background Rules

- The two apps should share a dark navy family, but not the same exact accent language.
- iTerm may be glassier; VS Code should be a little more solid.
- Avoid warm brown/orange translucent backgrounds in VS Code. They make the editor look sepia and visually merge with iTerm.
- Avoid stacking translucent backgrounds on nested editor elements. One glass/tint layer per visual surface only.
- Popups, menus, hovers, and suggestions should stay mostly opaque for readability.

## Border Rules

- Outer app/window border should be transparent unless explicitly testing window focus.
- iTerm/tmux internal structure uses amber/gold.
- VS Code internal structure uses blue/cyan and muted slate.
- Internal lines should be hairline-thin: prefer CSS `0.5px` inset shadows over VS Code native 1px borders when possible.
- Accent border lines should be fully opaque if they are hairlines. Avoid wide transparent colored borders.

## iTerm2 Target Settings

| Setting | Target |
| --- | --- |
| Background | `#111827` |
| Cursor | `#F5A524` |
| Selection | `#26324A` |
| Foreground | `#D6DEEB` |
| Muted text | `#7C859C` |
| Border | `#C4892F` |
| Opacity | `90%` |
| Blur | `25-35` |

## VS Code Target Settings

Use these as the conceptual targets for `Candiru Space` and its Vibrancy CSS:

```json
{
  "window.activeBorder": "#00000000",
  "window.inactiveBorder": "#00000000",
  "titleBar.activeBackground": "#0B1020",
  "titleBar.activeForeground": "#C0CAF5",
  "titleBar.inactiveBackground": "#070B14",
  "titleBar.inactiveForeground": "#565F89",
  "activityBar.background": "#0A0F1C",
  "activityBar.foreground": "#C0CAF5",
  "activityBar.inactiveForeground": "#565F89",
  "activityBar.activeBorder": "#7DCFFF",
  "sideBar.background": "#0B1020",
  "sideBar.foreground": "#C0CAF5",
  "sideBar.border": "#1F2335",
  "editor.background": "#111827",
  "editor.foreground": "#C0CAF5",
  "statusBar.background": "#0B1020",
  "statusBar.foreground": "#7DCFFF",
  "statusBar.border": "#1F2335",
  "panel.background": "#0B1020",
  "panel.border": "#1F2335",
  "terminal.background": "#0B1020",
  "terminal.foreground": "#C0CAF5"
}
```

## VS Code + Vibrancy

- Use `Candiru Space` as the VS Code color theme.
- Use Vibrancy Continued with a custom import CSS file.
- `vscode_vibrancy.type` should be `transparent` when avoiding macOS gray material haze.
- `vscode_vibrancy.backgroundOverride` should match the chosen VS Code navy, usually `#0B1020` or legacy `#0A0F24`.
- `vscode_vibrancy.disableColorCustomizations` should be `false` so Vibrancy can clear VS Code's stubborn background keys.
- VS Code native border colors should usually be transparent; the CSS import should draw thin blue/cyan hairlines.
- The CSS file should provide one glass surface per visual region; avoid repeated nested opaque layers.


## Desktop Composition

- Hide the menu bar so the wallpaper and app chrome feel calmer.
- Keep the desktop visually empty; screenshots go to `~/Pictures/Screenshots`, not the Desktop.
- iTerm2 is the warmer glass layer at about `90%` opacity.
- VS Code is the cooler, more solid layer at about `96%` opacity.
- Leave an `8-12px` gap between iTerm2 and VS Code when arranging them side by side.
- Use a subtle top vignette on the wallpaper so the hidden menu-bar edge and title bars read cleanly.


## Nebula Command Deck

- Native macOS menu bar stays hidden.
- SketchyBar replaces the top strip with a `32px` translucent command bar.
- Bar background: `#070B14` at roughly `70-85%` opacity.
- Bar bottom border: `#2F354D`.
- Left/workspace accent: `#F5A524`.
- Right/system accent: `#7AA2F7` and `#7DCFFF`.
- AeroSpace target gaps: `8px` inner and outer, with `40px` top outer gap for the bar.
- VS Code should be the cool matte work panel: navy base, blue/cyan accents, more solid than iTerm.
- iTerm stays the warm amber glass dashboard.


## Window Controls

AeroSpace uses `Ctrl+Cmd` as the main tiling modifier so it does not conflict with tmux/iTerm's `Alt/Option+h/j/k/l` pane navigation.

| Action | Shortcut |
| --- | --- |
| Focus window | `Ctrl+Cmd+h/j/k/l` |
| Move window | `Ctrl+Cmd+Shift+h/j/k/l` |
| Switch workspace | `Ctrl+Cmd+1-9` |
| Move window to workspace | `Ctrl+Cmd+Shift+1-9` |
| Toggle floating/tiling | `Ctrl+Cmd+Shift+Space` |
| Toggle fullscreen | `Ctrl+Cmd+Shift+F` |
| Open iTerm | `Ctrl+Cmd+Enter` |
| Reload AeroSpace | `Ctrl+Cmd+Shift+R` |
