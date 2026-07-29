local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close buffer" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>tt", function()
	vim.cmd("botright 15split | terminal")
end, { desc = "Terminal" })

map("n", "<leader>gl", function()
	vim.cmd("tabnew | terminal lazygit")
	vim.cmd("startinsert")
end, { desc = "Lazygit" })
