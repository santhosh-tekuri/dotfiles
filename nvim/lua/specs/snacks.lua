local spec = { "folke/snacks.nvim" }

function spec.config()
    require("snacks").setup {
        statuscolumn = {
            left = { "mark" },
            right = { "git" },
            refresh = 50,
        },
        terminal = {
            win = {
                position = "float",
                border = "single",
                wo = {
                    winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator",
                },
            }
        },
    }
    vim.keymap.set('n', '<C-/>', function() Snacks.terminal() end)
    vim.keymap.set('t', '<C-/>', function() Snacks.terminal() end)
end

return spec
