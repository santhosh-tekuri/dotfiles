-- show git changes in gutter

vim.pack.add { "https://github.com/lewis6991/gitsigns.nvim" }

require("gitsigns").setup {
    sign_priority = 100, -- priority for sign over diagnostic
}
