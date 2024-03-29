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
    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
        },
    })

    local cap1 = vim.lsp.protocol.make_client_capabilities()
    local cap2 = require("cmp_nvim_lsp").default_capabilities(cap1)
    local capabilities = vim.tbl_deep_extend("force", cap1, cap2)

    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts("Goto definition"))
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("Goto declaration"))
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts("Goto implementation"))
            vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts("Goto type definition"))
            vim.keymap.set('n', ' r', vim.lsp.buf.rename, opts("Rename symbol"))
            vim.keymap.set('n', ' k', vim.lsp.buf.hover, opts("Show docs for item under cursor"))
            vim.keymap.set({ 'n', 'i' }, '<c-k>', vim.lsp.buf.signature_help, opts("Show signature"))
            vim.keymap.set('n', ' e', vim.diagnostic.open_float, opts("Show error on current line"))

            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client.supports_method("textDocument/formatting") then
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

    local servers = {
        "lua_ls",
        "gopls",
        "rust_analyzer",
        "pyright",
    }
    -- install serve
    require("mason").setup()
    require("neodev").setup({})
    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }

    for _, server in ipairs(servers) do
        local config = {
            capabilities = capabilities,
        }
        local ok, settings = pcall(require, "lspsettings." .. server)
        if ok then
            config.settings = settings
        end
        require("lspconfig")[server].setup(config)
    end

    -- disable virtual text for diagnostics
    vim.diagnostic.config({ virtual_text = false })

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
