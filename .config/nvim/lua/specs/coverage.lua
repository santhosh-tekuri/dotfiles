-- displays coverage information in the sign column

vim.pack.add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/andythigpen/nvim-coverage"
}

require("coverage").setup()
