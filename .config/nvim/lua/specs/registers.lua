vim.pack.add { "https://github.com/tversteeg/registers.nvim" }

require("registers").setup {
    show = "0123456789abcdefghijklmnopqrstuvwxyz*+\"-/_=#%.:",
    show_empty = false,
    show_register_types = false,
    window = {
        transparency = 0,
    },
}
