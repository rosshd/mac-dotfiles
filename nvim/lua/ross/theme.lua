local M = {}

local c = {
	bg = "#070407",
	bg2 = "#12070d",
	surface = "#1b0d15",
	surface2 = "#28111d",
	selection = "#4b2231",
	fg = "#f3e4e8",
	fg2 = "#e5d0d6",
	muted = "#b99aa4",
	dim = "#7f5f6a",
	cherry = "#e58da0",
	cherry2 = "#d46a82",
	maroon = "#8a263d",
	plum = "#b69ac7",
	mist = "#b8c0d8",
}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply()
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	vim.o.background = "dark"
	vim.g.colors_name = "mystic_mycology"

	hl("Normal", { fg = c.fg, bg = c.bg })
	hl("NormalNC", { fg = c.fg2, bg = c.bg })
	hl("Cursor", { fg = c.bg, bg = c.cherry })
	hl("CursorLine", { bg = c.bg2 })
	hl("CursorLineNr", { fg = c.cherry, bold = true })
	hl("LineNr", { fg = c.dim })
	hl("SignColumn", { fg = c.dim, bg = c.bg })
	hl("ColorColumn", { bg = c.bg2 })
	hl("Visual", { bg = c.selection })
	hl("Search", { fg = c.bg, bg = c.cherry })
	hl("IncSearch", { fg = c.bg, bg = c.mist })
	hl("MatchParen", { fg = c.cherry, bold = true })
	hl("WinSeparator", { fg = c.maroon })
	hl("VertSplit", { fg = c.maroon })

	hl("Comment", { fg = c.muted, italic = true })
	hl("String", { fg = c.plum })
	hl("Character", { fg = c.plum })
	hl("Number", { fg = c.cherry })
	hl("Boolean", { fg = c.cherry })
	hl("Float", { fg = c.cherry })
	hl("Identifier", { fg = c.fg })
	hl("Function", { fg = c.cherry })
	hl("Statement", { fg = c.cherry2 })
	hl("Conditional", { fg = c.cherry2 })
	hl("Repeat", { fg = c.cherry2 })
	hl("Label", { fg = c.cherry2 })
	hl("Operator", { fg = c.cherry })
	hl("Keyword", { fg = c.cherry2 })
	hl("Exception", { fg = c.cherry2 })
	hl("PreProc", { fg = c.plum })
	hl("Include", { fg = c.plum })
	hl("Define", { fg = c.plum })
	hl("Macro", { fg = c.plum })
	hl("Type", { fg = c.mist })
	hl("StorageClass", { fg = c.mist })
	hl("Structure", { fg = c.mist })
	hl("Special", { fg = c.cherry })
	hl("Underlined", { fg = c.mist, underline = true })
	hl("Error", { fg = c.cherry2 })
	hl("Todo", { fg = c.bg, bg = c.cherry, bold = true })

	hl("Pmenu", { fg = c.fg, bg = c.surface })
	hl("PmenuSel", { fg = c.fg, bg = c.selection })
	hl("PmenuSbar", { bg = c.surface2 })
	hl("PmenuThumb", { bg = c.dim })
	hl("NormalFloat", { fg = c.fg, bg = c.surface })
	hl("FloatBorder", { fg = c.maroon, bg = c.surface })
	hl("FloatTitle", { fg = c.cherry, bg = c.surface, bold = true })

	hl("StatusLine", { fg = c.fg, bg = c.surface })
	hl("StatusLineNC", { fg = c.dim, bg = c.bg2 })
	hl("TabLine", { fg = c.muted, bg = c.bg2 })
	hl("TabLineFill", { bg = c.bg })
	hl("TabLineSel", { fg = c.cherry, bg = c.surface, bold = true })

	hl("DiagnosticError", { fg = c.cherry2 })
	hl("DiagnosticWarn", { fg = c.cherry })
	hl("DiagnosticInfo", { fg = c.mist })
	hl("DiagnosticHint", { fg = c.plum })
	hl("DiagnosticVirtualTextError", { fg = c.cherry2, bg = c.bg2 })
	hl("DiagnosticVirtualTextWarn", { fg = c.cherry, bg = c.bg2 })
	hl("DiagnosticVirtualTextInfo", { fg = c.mist, bg = c.bg2 })
	hl("DiagnosticVirtualTextHint", { fg = c.plum, bg = c.bg2 })

	hl("GitSignsAdd", { fg = c.plum })
	hl("GitSignsChange", { fg = c.cherry })
	hl("GitSignsDelete", { fg = c.cherry2 })
	hl("DiffAdd", { fg = c.plum, bg = "#201526" })
	hl("DiffChange", { fg = c.cherry, bg = "#24121a" })
	hl("DiffDelete", { fg = c.cherry2, bg = "#251017" })
	hl("DiffText", { fg = c.cherry, bg = c.selection })

	hl("TelescopeBorder", { fg = c.maroon, bg = c.surface })
	hl("TelescopeNormal", { fg = c.fg, bg = c.surface })
	hl("TelescopePromptBorder", { fg = c.cherry, bg = c.surface2 })
	hl("TelescopePromptNormal", { fg = c.fg, bg = c.surface2 })
	hl("TelescopePromptPrefix", { fg = c.cherry })
	hl("TelescopeSelection", { fg = c.fg, bg = c.selection })
	hl("TelescopeMatching", { fg = c.cherry, bold = true })
end

return M
