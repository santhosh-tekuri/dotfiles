local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
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

    -- install serve
    require("mason").setup()
    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }

    -- setup each server
    local lspconfig = require "lspconfig"
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    for _, server in pairs(servers) do
        local opts = {
            capabilities = capabilities,
        }
        local ok, settings = pcall(require, "lspsettings." .. server)
        if ok then
            opts.settings = settings
        end
        lspconfig[server].setup(opts)
    end

    -- when LS attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Buffer local mappings.
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set({ 'n', 'v' }, '<space>a', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<space>k', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      end,
    })

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
