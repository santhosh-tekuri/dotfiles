local spec = { "folke/trouble.nvim" }

function spec.config()
    local trouble = require("trouble")
    require("trouble").setup {
        icons = false,
        padding = false,
    }

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TroubleLspAttach', {}),
        callback = function(ev)
            vim.keymap.set('n', 'gr', function()
                trouble.toggle("lsp_references")
            end, { desc = "Goto references" })
            vim.keymap.set('n', ' d', function()
                trouble.toggle("document_diagnostics")
            end, { desc = "Open diagnostic picker" })
            vim.keymap.set('n', ' D', function()
                trouble.toggle("workspace_diagnostics")
            end, { desc = "Open workspace diagnotic picker" })
      end,
    })
end

return spec
