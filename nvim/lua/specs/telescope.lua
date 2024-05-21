-- fuzzy finder

local spec = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
    },
}

function spec.config()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', ' f', builtin.find_files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', function()
        builtin.buffers { ignore_current_buffer = true }
    end, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', builtin.live_grep, { desc = "Global search in workspace folder" })

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TelescopeLspConfig', {}),
        callback = function(_ev)
            vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = "Goto definition" })
            vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = "Goto implementation" })
            vim.keymap.set('n', 'gy', builtin.lsp_type_definitions, { desc = "Goto type definition" })
            vim.keymap.set('n', ' s', builtin.lsp_document_symbols, { desc = "Open symbol picker" })
            vim.keymap.set('n', ' S', builtin.lsp_dynamic_workspace_symbols, { desc = "Open workspace symbol picker" })
            vim.keymap.set({ 'n', 'v' }, ' a', vim.lsp.buf.code_action, { desc = "Perform code action" })
        end,
    });

    -- horizontal_fused layout strategy
    local layout_strategies = require("telescope.pickers.layout_strategies")
    layout_strategies.horizontal_fused = function(picker, max_columns, max_lines, layout_config)
        local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
        layout.prompt.title = ""
        layout.results.title = ""
        layout.preview.title = ""
        layout.results.height = layout.results.height + 1
        layout.results.borderchars = { "─", "│", "─", "│", "╭", "┬", "┤", "├" }
        layout.preview.borderchars = { "─", "│", "─", " ", "─", "╮", "╯", "─" }
        layout.prompt.borderchars = { "─", "│", "─", "│", "╭", "╮", "┴", "╰" }
        return layout
    end

    local actions = require("telescope.actions")
    require("telescope").setup({
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown {},
            },
        },
        defaults = {
            path_display = { "filename_first" },
            layout_strategy = "horizontal_fused",
            mappings = {
                i = {
                    ["<esc>"] = actions.close, -- close telescope with single <esc>
                    ["<c-t>"] = require("trouble.sources.telescope").open,
                },
                n = {
                    ["<c-t>"] = require("trouble.sources.telescope").open,
                },
            },
        },
    })
    require("telescope").load_extension("ui-select")
end

return spec

--[[
<space>f    files
<space>b    buffers
<space>/    grep in workspace
<space>a    code actions

<space>s    document symbols
<space>S    workspace symbols

<space>w    enter window mode
--]]
