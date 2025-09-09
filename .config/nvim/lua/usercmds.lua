vim.api.nvim_create_user_command('SudoWrite', function()
    local tmp = vim.fn.tempname()
    vim.cmd('write! ' .. tmp)
    vim.cmd('terminal sudo tee % < ' .. tmp .. ' > /dev/null')
    vim.cmd('e!')
end, {})

vim.api.nvim_create_user_command("W", "noautocmd w", {})

local function runCommand(args, auto_close)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = vim.o.columns,
        height = vim.o.lines,
        row = 0,
        col = 0,
        style = "minimal",
        zindex = 250,
    })
    vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = win })
    vim.cmd.terminal(args)
    if auto_close then
        vim.api.nvim_create_autocmd('TermClose', {
            desc = "close terminal",
            buffer = buf,
            callback = function()
                vim.api.nvim_buf_delete(buf, {})
            end,
        })
    end
end

vim.api.nvim_create_user_command('RunCmd', function(args)
    runCommand(args.args, false)
end, { nargs = "+", desc = "Run Command" })

vim.api.nvim_create_user_command('RunTui', function(args)
    runCommand(args.args, true)
end, {
    nargs = "+",
    desc = "Run TUI command"
})

vim.keymap.set('n', '<leader>g', "<cmd>RunTui lazygit<cr>", { desc = "launch lazygit" })
