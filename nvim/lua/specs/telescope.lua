local spec = {
  "nvim-telescope/telescope.nvim", tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
}

function spec.config()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', ' f', builtin.find_files, {})
  vim.keymap.set('n', ' b', builtin.buffers, {})
  vim.keymap.set('n', ' s', builtin.lsp_document_symbols, {})
  vim.keymap.set('n', ' S', builtin.lsp_workspace_symbols, {})

  local actions = require("telescope.actions")
  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<esc>"] = actions.close, -- close telescope with single <esc>
        },
      },
    },
  })
end

return spec
