-- smart jump in insert mode

vim.keymap.set("i", "<C-L>", function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    line = line - 1
    local node = vim.treesitter.get_node()
    if node ~= nil then
        local row
        row, col = node:end_()
        vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end
end, { desc = "smart tab" })
