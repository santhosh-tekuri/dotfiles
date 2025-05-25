-- syntax aware text-objects, select, move, swap, and peek support

local spec = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
}

function spec.config()
    require("nvim-treesitter-textobjects").setup {
        select = {
            lookahead = true,
        }
    }
    local keymap = {
        ['i='] = "@assignment.inner",
        ['l='] = "@assignment.lhs",
        ['r='] = "@assignment.rhs",
        ['af'] = "@call.outer",
        ['if'] = "@call.inner",
        ['aa'] = "@parameter.outer",
        ['ia'] = "@parameter.inner",
    }
    local select = require("nvim-treesitter-textobjects.select")
    for key, query in pairs(keymap) do
        vim.keymap.set({ "x", "o" }, key, function()
            select.select_textobject(query, "textobjects")
        end)
    end
end

return spec
