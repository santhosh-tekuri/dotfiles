local spec = { "catppuccin/nvim" }

function spec.config()
  require("catppuccin").setup({
    flavour = "mocha",
  })
  vim.cmd "colorscheme catppuccin"
end

return spec
