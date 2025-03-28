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
                backdrop = false,
                wo = {
                    winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator",
                },
            }
        },
        picker = {
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
    vim.keymap.set('n', ' f', Snacks.picker.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', function()
        Snacks.picker.buffers {
            current = false,
        }
    end, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', Snacks.picker.grep, { desc = "Global search in workspace folder" })

    vim.keymap.set('n', '<C-/>', function() Snacks.terminal() end)
    vim.keymap.set('t', '<C-/>', function() Snacks.terminal() end)

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TelescopeLspConfig', {}),
        callback = function(_ev)
            vim.keymap.set('n', 'gd', Snacks.picker.lsp_definitions, { desc = "Goto definition" })
            vim.keymap.set('n', 'gi', Snacks.picker.lsp_implementations, { desc = "Goto implementation" })
            vim.keymap.set('n', 'gy', Snacks.picker.lsp_type_definitions, { desc = "Goto type definition" })
            vim.keymap.set('n', ' s', Snacks.picker.lsp_symbols, { desc = "Open symbol picker" })
            vim.keymap.set('n', ' S', Snacks.picker.lsp_workspace_symbols, { desc = "Open workspace symbol picker" })
            vim.keymap.set({ 'n', 'v' }, ' a', vim.lsp.buf.code_action, { desc = "Perform code action" })
        end,
    });
end

return spec
