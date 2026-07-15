local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"JetBrains Mono",
	"SF Mono",
})
config.font_size = 14.0
config.colors = {
	foreground = "#f3e4e8",
	background = "#2a1620",
	cursor_bg = "#e58da0",
	cursor_fg = "#070407",
	cursor_border = "#e58da0",
	selection_fg = "#f3e4e8",
	selection_bg = "#4b2231",
	scrollbar_thumb = "#5c2635",
	split = "#6b2a3c",
	ansi = {
		"#0b060a",
		"#d46a82",
		"#b69ac7",
		"#c9637a",
		"#b8c0d8",
		"#c79acb",
		"#c7a9b4",
		"#f3e4e8",
	},
	brights = {
		"#33202a",
		"#e58da0",
		"#d1b4dc",
		"#e58da0",
		"#d0d5e7",
		"#ddb5df",
		"#e2c5ce",
		"#fff4f6",
	},
	tab_bar = {
		background = "#070407",
		active_tab = { bg_color = "#4b2231", fg_color = "#fff4f6", intensity = "Bold" },
		inactive_tab = { bg_color = "#12070d", fg_color = "#b99aa4" },
		inactive_tab_hover = { bg_color = "#2a101c", fg_color = "#f3e4e8" },
		new_tab = { bg_color = "#070407", fg_color = "#c9637a" },
		new_tab_hover = { bg_color = "#2a101c", fg_color = "#f3e4e8" },
	},
}
config.window_background_opacity = 0.56
config.text_background_opacity = 0.98
config.macos_window_background_blur = 100
config.inactive_pane_hsb = {
	saturation = 0.82,
	brightness = 0.9,
}
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
