vim.api.nvim_create_user_command('SudoWrite', function()
    local tmp = vim.fn.tempname()
    vim.cmd('write! ' .. tmp)
    vim.cmd('terminal sudo tee % < ' .. tmp .. ' > /dev/null')
    vim.cmd('e!')
end, {})

vim.api.nvim_create_user_command("W", "noautocmd w", {})
