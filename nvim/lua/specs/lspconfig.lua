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
        "pyright",
    }

    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
        },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local on_attach = function(client, bufnr)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Goto definition" })
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Goto declaration" })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Goto implementation" })
        vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = "Goto type definition" })
        vim.keymap.set('n', ' r', vim.lsp.buf.rename, { desc = "Rename symbol" })
        vim.keymap.set('n', ' k', vim.lsp.buf.hover, { desc = "Show docs for item under cursor" })
        vim.keymap.set({ 'n', 'i' }, '<c-k>', vim.lsp.buf.signature_help, { desc = "Show signature" })
        vim.keymap.set('n', ' e', vim.diagnostic.open_float, { desc = "Show error on current line" })

        if client.supports_method("textDocument/formatting") then
            local group = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
            vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = group,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end
    end

    -- install serve
    require("mason").setup()
    require("neodev").setup({})
    require("mason-lspconfig").setup {
        ensure_installed = servers,
        handlers = {
            function(server_name)
                local opts = {
                    capabilities = capabilities,
                    on_attach = on_attach,
                }
                local ok, settings = pcall(require, "lspsettings." .. server_name)
                if ok then
                    opts.settings = settings
                end
                require("lspconfig")[server_name].setup(opts)
            end,
        },
    }

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

    -- options for vim.lsp.hover floating window
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
            max_width = 80
        }
    )
end

return spec
