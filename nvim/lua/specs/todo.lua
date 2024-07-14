-- highlight, list and search todo comments

local spec = {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
}

function spec.config()
    local todo = require("todo-comments")
    todo.setup()
    vim.keymap.set('n', ']t', todo.jump_next)
    vim.keymap.set('n', '[t', todo.jump_prev)

    local ok, _ = pcall(require, "trouble")
    if ok then
        vim.keymap.set('n', ' t', function() vim.cmd("TodoTrouble") end, { desc = "show todos" })
    end
end

return spec
