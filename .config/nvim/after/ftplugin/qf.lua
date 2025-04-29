vim.opt.relativenumber = false
vim.opt.signcolumn = "no"

vim.keymap.set('n', 'q', function()
    vim.cmd('q')
end)
