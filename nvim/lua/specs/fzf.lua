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
    })

    vim.keymap.set('n', ' f', fzf.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', fzf.buffers, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', fzf.live_grep, { desc = "Global search in workspace folder" })

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('FzfLspConfig', {}),
        callback = function(ev)
            local fzf = require("fzf-lua")
            vim.keymap.set('n', 'gr', fzf.lsp_references, { desc = "Goto references" })
            vim.keymap.set('n', ' d', function()
                fzf.diagnostics_document({ fzf_opts = {
                    ['--delimiter'] = ':',
                    ['--with-nth'] = '2,4',
                }})
            end, { desc = "Open diagnostic picker" })
            vim.keymap.set('n', ' D', fzf.diagnostics_workspace, { desc = "Open workspace diagnotic picker" })
            vim.keymap.set('n', ' s', fzf.lsp_document_symbols, { desc = "Open symbol picker" })
            vim.keymap.set('n', ' S', fzf.lsp_workspace_symbols, { desc = "Open workspace symbol picker" })
            vim.keymap.set({ 'n', 'v'} , ' a', fzf.lsp_code_actions, { desc = "Perform code action" })
      end,
    })
end

return spec
