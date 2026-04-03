vim.pack.add { "https://github.com/santhosh-tekuri/term.nvim" }
-- dir = "~/gh/santhosh-tekuri/term.nvim",

vim.keymap.set({ "n", "t" }, "<c-/>", "<CMD>ToggleTerm<cr>")
vim.keymap.set({ "n", "t" }, "<c-s-/>", "<CMD>PickTerm<cr>")
vim.keymap.set("n", "<leader>q", "<CMD>SafeQuit<cr>")
vim.keymap.set('n', '<leader>G', "<cmd>RunCmd! lazygit<cr>", { desc = "launch lazygit" })
