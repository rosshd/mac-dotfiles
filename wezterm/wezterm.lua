local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "JetBrains Mono",
  "SF Mono",
})
config.font_size = 14.0
config.color_scheme = "Tokyo Night"
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.native_macos_fullscreen_mode = false
config.default_prog = { "/opt/homebrew/bin/fish", "-lc", "ship" }
config.initial_cols = 160
config.initial_rows = 44

config.keys = {
  { key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
  { key = "LeftArrow", mods = "OPT", action = wezterm.action.SendString("\x1bb") },
  { key = "RightArrow", mods = "OPT", action = wezterm.action.SendString("\x1bf") },
  { key = "l", mods = "CTRL|OPT|CMD", action = wezterm.action.DisableDefaultAssignment },
}

local openlearn_font_size = 20.0
local openlearn_previous_font_sizes = {}

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  local screen = wezterm.gui.screens().active
  local width = math.floor(screen.width * 0.9)
  local height = math.floor(screen.height * 0.9)
  local x = screen.x + math.floor((screen.width - width) / 2)
  local y = screen.y + math.floor((screen.height - height) / 2)

  local gui_window = window:gui_window()
  gui_window:set_inner_size(width, height)
  gui_window:set_position(x, y)
end)

wezterm.on("user-var-changed", function(window, _, name, value)
  if name ~= "openlearn_active" then
    return
  end

  local window_id = window:window_id()
  local overrides = window:get_config_overrides() or {}
  if value == "1" then
    if openlearn_previous_font_sizes[window_id] == nil then
      openlearn_previous_font_sizes[window_id] = overrides.font_size or false
    end
    overrides.font_size = openlearn_font_size
  else
    local previous_font_size = openlearn_previous_font_sizes[window_id]
    if previous_font_size == false then
      overrides.font_size = nil
    else
      overrides.font_size = previous_font_size
    end
    openlearn_previous_font_sizes[window_id] = nil
  end

  window:set_config_overrides(overrides)
end)

return config
