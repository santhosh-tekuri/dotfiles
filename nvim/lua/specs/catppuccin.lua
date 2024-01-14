local spec = { "catppuccin/nvim" }

function spec.config()
  require("catppuccin").setup({
    flavour = "mocha",
    color_overrides = {
      mocha = {
        base = "#2c2e34",
        mantle = "#3b3e48",
      }
    },
    custom_highlights = function(colors)
      return {
        GitSignsChange = { fg = "#e59b77" },
      }
    end
  })
  vim.cmd "colorscheme catppuccin"
end

return spec
