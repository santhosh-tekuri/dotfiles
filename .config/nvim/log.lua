function Log(...)
    local bufnr = vim.fn.bufnr("debug.log")
    if bufnr == -1 then
        bufnr = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(bufnr, "debug.log")
        vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
        vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = bufnr })
        vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
    end
    for _, val in ipairs({ ... }) do
        if type(val) ~= "string" then
            val = vim.inspect(val)
        end
        local lines = vim.split(val, "\n")
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
    end
end
