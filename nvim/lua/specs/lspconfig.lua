local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
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

end

return spec
