-- lsp related keymaps and config
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local function opts(desc)
            return { buffer = ev.buf, desc = desc }
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("Goto declaration"))
        vim.keymap.set('n', ' r', vim.lsp.buf.rename, opts("Rename symbol"))
        vim.keymap.set({ 'n', 'v' }, ' k', vim.lsp.buf.hover, opts("Show docs for item under cursor"))
        vim.keymap.set({ 'n', 'i' }, '<c-k>', vim.lsp.buf.signature_help, opts("Show signature"))
        vim.keymap.set('n', ' e', vim.diagnostic.open_float, opts("Show error on current line"))

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client ~= nil and client.supports_method("textDocument/formatting") then
            local group = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
            vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = group,
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end
    end,
})

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
