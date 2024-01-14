local spec = {
  "nvim-telescope/telescope.nvim", tag = "0.1.5"
}

function spec.config()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', ' f', builtin.find_files, {})
  vim.keymap.set('n', ' b', builtin.buffers, {})

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
