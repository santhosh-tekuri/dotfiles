local spec = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    }
}

function spec.config()
    require("nvim-treesitter.configs").setup {
        textobjects = {
            select = {
                enable = true,
                lookahead = true,

                keymaps = {
                    ['a='] = { query = "@assignment.outer" },
                    ['i='] = { query = "@assignment.inner" },
                    ['l='] = { query = "@assignment.lhs" },
                    ['r='] = { query = "@assignment.rhs" },

                    ['af'] = { query = "@call.outer" },
                    ['if'] = { query = "@call.inner" },

                    ['aa'] = { query = "@parameter.outer" },
                    ['ia'] = { query = "@parameter.inner" },
                }
            }
        }
    }
end

return spec
