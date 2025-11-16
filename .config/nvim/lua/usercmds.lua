local redir_buf
vim.api.nvim_create_user_command('Redir', function(cmd)
    if cmd.args:sub(1, 1) == '!' then
        vim.api.nvim_echo({ { "Use terminal for shell commands", "ErrorMsg" } }, false, {})
        return
    end
    local messages = vim.fn.execute(cmd.args, "silent")
    if #messages == 0 then
        vim.api.nvim_echo({ { "No Output", "WarningMsg" } }, false, {})
        return
    end
    if cmd.args == "messages" and messages:sub(1, 1) == '\n' then
        messages = messages:sub(2)
    end
    local lines = vim.split(messages, "\n")
    if #lines > 0 then
        local buf
        if cmd.bang and vim.api.nvim_buf_is_valid(redir_buf) then
            buf = redir_buf
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        else
            buf = vim.api.nvim_create_buf(false, true)
            vim.b[buf].wipe = true
            vim.bo[buf].bufhidden = 'wipe'
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.cmd("rightbelow 10split | buffer " .. buf)
            vim.wo.winfixbuf = true
        end
        redir_buf = buf
    end
end, { nargs = '+', complete = "command", bang = true })

vim.api.nvim_create_user_command('SudoWrite', function()
    local tmp = vim.fn.tempname()
    vim.cmd('write! ' .. tmp)
    vim.cmd('terminal sudo tee % < ' .. tmp .. ' > /dev/null')
    vim.cmd('e!')
end, {})

vim.api.nvim_create_user_command("W", "noautocmd w", {})
