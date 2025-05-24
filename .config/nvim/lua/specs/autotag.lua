-- automatically close and rename html tag

local spec = {
    "windwp/nvim-ts-autotag",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    }
}

function spec.config()
    require("nvim-treesitter.configs").setup {
        autotag = {
            enable = true
        }
    }
end

return spec
