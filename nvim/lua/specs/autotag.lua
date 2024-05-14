-- automatically close and rename html tag

local spec = { "windwp/nvim-ts-autotag" }

function spec.config()
    require("nvim-treesitter.configs").setup {
        autotag = {
            enable = true
        }
    }
end

return spec
