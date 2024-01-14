local spec = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  }
}

function spec.config()
  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "rust_analyzer", "gopls" },
  })

  require("lspconfig").lua_ls.setup {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        }
      }
    }
  }

  require("lspconfig").gopls.setup {}
  require("lspconfig").rust_analyzer.setup {}
end

return spec
