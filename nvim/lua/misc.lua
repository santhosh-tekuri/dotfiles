-- highlight selection on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Hightlight selection on yank",
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 600 })
    end,
})

-- disable virtual text for diagnostics
vim.diagnostic.config({ virtual_text = false })

-- set diagnotic signs
local signs = {
    { name = 'DiagnosticSignError', text = '' },
    { name = 'DiagnosticSignWarn', text = '' },
    { name = 'DiagnosticSignHint', text = '' },
    { name = 'DiagnosticSignInfo', text = '' },
}
for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
end

-- options for vim.lsp.hover floating window (for golang popup is too wide)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        max_width = 80
    }
)
