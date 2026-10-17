-- file explorer: edit your filesystem like a buffer

vim.pack.add { "https://github.com/stevearc/oil.nvim" }

require("oil").setup {
    float = {
        max_width = 70,
        max_height = 20,
        border = "single",
        win_options = {
            winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator",
        }
    }
}
vim.keymap.set("n", "<leader>e", "<CMD>Oil --float<CR>", { desc = "Explore parent directory" })

--[[
<leader>e       open file explorer
--]]
