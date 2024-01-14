local spec = { "catppuccin/nvim" }

function spec.config()
  require("catppuccin").setup({
    flavour = "mocha",
    color_overrides = {
      mocha = {
        base = "#2c2e34",
        mantle = "#3b3e48",
      }
    }
  })
  vim.cmd "colorscheme catppuccin"
end

return spec
