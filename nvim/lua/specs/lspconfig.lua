local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
}

function spec.config()
    local servers = {
        "gopls",
        "rust_analyzer",
    }

    local lspconfig = require "lspconfig"
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    for _, server in pairs(servers) do
        local opts = {
            capabilities = capabilities,
        }
        local ok, settings = pcall(require, "lspsettings." .. server)
        if ok then
            opts = vim.tbl_deep_extend("force", settings, opts)
        end
        lspconfig[server].setup(opts)
    end

    require("mason").setup()
    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }
end

return spec
