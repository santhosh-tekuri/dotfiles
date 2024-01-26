local spec = {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
    },
}

function spec.config()
    local builtin = require('telescope.builtin')
    -- vim.keymap.set('n', ' f', builtin.find_files, { desc = "Open file picker" })
    -- vim.keymap.set('n', ' b', builtin.buffers, { desc = "Open buffer picker" })
    -- vim.keymap.set('n', ' /', builtin.live_grep, { desc = "Global search in workspace folder" })

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TelescopeLspConfig', {}),
        callback = function(ev)
            -- vim.keymap.set('n', ' s', builtin.lsp_document_symbols, { desc = "Open symbol picker" })
            -- vim.keymap.set('n', ' S', builtin.lsp_workspace_symbols, { desc = "Open workspace symbol picker" })
            -- vim.keymap.set({ 'n', 'v' }, ' a', vim.lsp.buf.code_action, { desc = "Perform code action" })
        end,
    });

    local actions = require("telescope.actions")
    require("telescope").setup({
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown {},
            },
        },
        defaults = {
            mappings = {
                i = {
                    ["<esc>"] = actions.close, -- close telescope with single <esc>
                },
            },
        },
    })
    require("telescope").load_extension("ui-select")
end

return spec
