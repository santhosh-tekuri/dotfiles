local spec = { "folke/snacks.nvim" }

function spec.config()
    require("snacks").setup {
        scroll = {},
        statuscolumn = {
            left = { "mark" },
            right = { "git" },
            refresh = 50,
        },
        terminal = {
            win = {
                position = "float",
                backdrop = false,
                wo = {
                    winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator",
                },
                width = 0,
                height = function()
                    return vim.fn.winheight(0)
                end,
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
    vim.keymap.set({ 'n', 't' }, '<C-/>', function() Snacks.terminal() end)

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TelescopeLspConfig', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gd', Snacks.picker.lsp_definitions, opts("Goto definition"))
            vim.keymap.set('n', 'gi', Snacks.picker.lsp_implementations, opts("Goto implementation"))
            vim.keymap.set('n', 'gy', Snacks.picker.lsp_type_definitions, opts("Goto type definition"))
            vim.keymap.set('n', ' s', Snacks.picker.lsp_symbols, opts("Open symbol picker"))
            vim.keymap.set('n', ' S', Snacks.picker.lsp_workspace_symbols, opts("Open workspace symbol picker"))
            vim.keymap.set({ 'n', 'v' }, ' a', vim.lsp.buf.code_action, opts("Perform code action"))
        end,
    });
end

return spec
