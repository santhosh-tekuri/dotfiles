-- displays a popup with possible keybindings of the command you started typing

return {
    "folke/which-key.nvim",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {},
}
