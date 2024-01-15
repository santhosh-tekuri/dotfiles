local M = {
  "neovim/nvim-lspconfig",
}

function M.config()
  local lspconfig = require "lspconfig"

  local servers = {
    "gopls",
    "rust_analyzer",
  }

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  for _, server in pairs(servers) do
    local opts = {
      capabilities = capabilities,
    }

    local ok, settings = pcall(require, "user.lspsettings." .. server)
    if ok then
      opts = vim.tbl_deep_extend("force", settings, opts)
    end

    lspconfig[server].setup(opts)
  end
end

return M
