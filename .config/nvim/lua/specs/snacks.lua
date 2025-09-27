local spec = { "folke/snacks.nvim" }

function spec.config()
    require("snacks").setup {
        picker = {
            ui_select = false,
            on_show = function()
                -- workaround: when open in terminal mode, force insert mode
                vim.schedule(vim.cmd.startinsert)
            end,
            auto_confirm = true,
            formatters = {
                file = {
                    filename_first = true,
                },
            },
            icons = {
                files = {
                    enabled = false,
                },
            },
            layouts = {
                default = {
                    layout = {
                        backdrop = false,
                    },
                },
            },
            win = {
                input = {
                    keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
                preview = {
                    wo = {
                        number = false,
                        statuscolumn = "",
                        fillchars = "eob: ",
                    },
                }
            }
        }
    }
end

return spec
