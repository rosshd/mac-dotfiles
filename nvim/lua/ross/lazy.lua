local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	{ "folke/which-key.nvim", opts = {} },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{ "tpope/vim-sleuth" },
	{ "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" } },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "echasnovski/mini.pairs", version = false, opts = {} },
	{ "echasnovski/mini.statusline", version = false, opts = {} },
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = false,
			view_options = { show_hidden = true },
			keymaps = { ["q"] = "actions.close" },
		},
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
			{ "<leader>e", "<cmd>Oil<cr>", desc = "Edit files" },
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep text" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					layout_strategy = "flex",
					sorting_strategy = "ascending",
					layout_config = { prompt_position = "top" },
					mappings = {
						i = { ["<esc>"] = actions.close },
					},
				},
			}
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = { delay = 600 },
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = vim.keymap.set
				local opts = { buffer = bufnr }
				map("n", "]h", gs.next_hunk, vim.tbl_extend("force", opts, { desc = "Next hunk" }))
				map("n", "[h", gs.prev_hunk, vim.tbl_extend("force", opts, { desc = "Previous hunk" }))
				map("n", "<leader>gp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
				map("n", "<leader>gr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
				map("n", "<leader>gs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
			end,
		},
	},
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
			{ "<leader>gD", "<cmd>DiffviewOpen --staged<cr>", desc = "Diff staged" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff" },
		},
		opts = {
			enhanced_diff_hl = true,
			view = { default = { layout = "diff2_horizontal" }, merge_tool = { layout = "diff3_mixed" } },
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
			},
		},
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format",
			},
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = true, auto_refresh = false },
			suggestion = {
				enabled = true,
				auto_trigger = false,
				keymap = {
					accept = "<C-J>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = { markdown = true, help = false, gitcommit = true },
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("ross.lsp")
		end,
	},
}, {
	ui = { border = "rounded" },
	checker = { enabled = true, notify = false },
})
