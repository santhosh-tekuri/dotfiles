-- use <C-L> in insert mode to jump to end of current treesitter node

vim.keymap.set("i", "<C-L>", function()
    local node = vim.treesitter.get_node()
    if node ~= nil then
        local row, col = node:end_()
        pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
    end
end, { desc = "insjump" })
