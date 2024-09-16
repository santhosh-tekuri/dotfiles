local spec = { "catppuccin/nvim" }

function spec.config()
    require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
            mocha = {
                base = "#000000",
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
