-- lsp servers installation and integration

local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "folke/neodev.nvim", -- for neovim plugin development
    },
}

function spec.config()
    local cap1 = vim.lsp.protocol.make_client_capabilities()
    local cap2 = require("cmp_nvim_lsp").default_capabilities(cap1)
    local capabilities = vim.tbl_deep_extend("force", cap1, cap2)

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

    local servers = {
        "lua_ls",
        "gopls",
        "golangci_lint_ls",
        "rust_analyzer",
        "pyright",
        "jsonls",
        "yamlls",
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
end

return spec

--[[
gd          goto definition
gD          goto declaration
gy          goto type definition
gi          goto implemenation

<space>r    rename
<space>e    show error
<space>k    show doc
<ctrl>k     show signature
--]]
