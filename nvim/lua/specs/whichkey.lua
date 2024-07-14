-- displays a popup with possible keybindings of the command you started typing

return {
    "folke/which-key.nvim",
    opts = {
        preset = "helix",
        icons = {
            rules = false,
        },
        win = {
            height = { max = 35 },
        }
    },
}
