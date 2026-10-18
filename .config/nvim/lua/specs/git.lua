require("specs.picker")
vim.pack.add { "https://github.com/santhosh-tekuri/git.nvim" }

vim.keymap.set('n', '<leader>g', "<cmd>GitStatus<cr>")
