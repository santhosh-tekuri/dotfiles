local spec = {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "williamboman/mason.nvim",
    },
}

function spec.config()
    local servers = {
        "gopls",
        "rust_analyzer",
    }

    require("mason").setup()
    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }
end

return spec
