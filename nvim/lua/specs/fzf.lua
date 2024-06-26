local spec = {
    "ibhagwan/fzf-lua",
}

function spec.config()
    local fzf = require("fzf-lua")
    fzf.setup({
        winopts = {
            width = 0.9,
            col = 0.5,
            preview = {
                vertial = 'down:50%',
                horizontal = 'right:50%',
            }
        },
        defaults = {
            formatter = "path.filename_first",
        },
    })

    vim.keymap.set('n', ' f', fzf.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', fzf.buffers, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', fzf.live_grep, { desc = "Global search in workspace folder" })

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('FzfLspConfig', {}),
        callback = function(_ev)
            vim.keymap.set('n', 'gd', fzf.lsp_definitions, { desc = "Goto definition" })
            vim.keymap.set('n', 'gi', fzf.lsp_implementations, { desc = "Goto implementation" })
            vim.keymap.set('n', 'gy', fzf.lsp_definitions, { desc = "Goto type definition" })
            vim.keymap.set('n', ' s', fzf.lsp_document_symbols, { desc = "Open symbol picker" })
            vim.keymap.set('n', ' S', fzf.lsp_live_workspace_symbols, { desc = "Open workspace symbol picker" })
            vim.keymap.set({ 'n', 'v' }, ' a', fzf.lsp_code_actions, { desc = "Perform code action" })
        end,
    })
end

return spec
