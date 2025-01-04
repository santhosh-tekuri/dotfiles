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
    local cap2
    local ok, cmp = pcall(require, "cmp_nvim_lsp")
    if ok then
        cap2 = cmp.default_capabilities(cap1)
    else
        cap2 = require("blink.cmp").get_lsp_capabilities()
    end
    local capabilities = vim.tbl_deep_extend("force", cap1, cap2)

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
