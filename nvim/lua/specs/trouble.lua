-- pretty diagnostics, references, telescope results, quickfix and location list
-- to help you solve allow the trouble your code is causing

local spec = { "folke/trouble.nvim" }

function spec.config()
    require("trouble").setup {
        focus = true,
        padding = false,
        use_diagnostic_signs = true,
    }

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('TroubleLspAttach', {}),
        callback = function(_ev)
            vim.keymap.set('n', 'gr', "<cmd>Trouble lsp_references toggle<cr>",
                { desc = "Goto references" })
            vim.keymap.set('n', ' d', "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                { desc = "Open diagnostic picker" })
            vim.keymap.set('n', ' D', "<cmd>Trouble diagnostics toggle<cr>",
                { desc = "Open workspace diagnotic picker" })
        end,
    })
end

return spec

--[[
gr          goto references

<space>d    current diagnostics
<space>D    workspace diagnotics
--]]
