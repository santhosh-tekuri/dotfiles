local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "nvimtools/none-ls.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "folke/neodev.nvim", -- for neovim plugin development
    },
}

function spec.config()
    local servers = {
        "lua_ls",
        "gopls",
        "rust_analyzer",
    }

    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
        },
    })

    -- install serve
    require("mason").setup()
    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }

    -- setup each server
    require("neodev").setup({})
    local lspconfig = require "lspconfig"
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local on_attach = function(client, bufnr)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Goto definition"} )
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Goto declaration" })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Goto implementation" })
        vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = "Goto type definition" })
        vim.keymap.set('n', ' r', vim.lsp.buf.rename, { desc = "Rename symbol" })
        vim.keymap.set('n', ' k', vim.lsp.buf.hover, { desc = "Show docs for item under cursor" })
        vim.keymap.set({'n', 'i'}, '<c-k>', vim.lsp.buf.signature_help, { desc = "Show signature" })
        vim.keymap.set('n', ' e', function()
            vim.diagnostic.open_float(nil, {focus=false})
        end, { desc = "Show error on current line" })
    end
    for _, server in pairs(servers) do
        local opts = {
            capabilities = capabilities,
            on_attach = on_attach,
        }
        local ok, settings = pcall(require, "lspsettings." .. server)
        if ok then
            opts.settings = settings
        end
        lspconfig[server].setup(opts)
    end

    -- set diagnotic text
    local signs = {
        { name = 'DiagnosticSignError', text = '' },
        { name = 'DiagnosticSignWarn', text = '' },
        { name = 'DiagnosticSignHint', text = '' },
        { name = 'DiagnosticSignInfo', text = '' },
    }
    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end

end

return spec
