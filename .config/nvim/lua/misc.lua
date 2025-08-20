vim.cmd("autocmd TermOpen * startinsert")

vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Format on save",
    callback = function()
        if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
            vim.lsp.buf.format()
        end
    end
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Hilight & copy on yank",
    callback = function()
        if vim.v.operator == 'y' then
            vim.fn.setreg("+", vim.fn.getreg("0"))
            vim.hl.on_yank({ higroup = 'IncSearch', timeout = 600 })
        end
    end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
    desc = "No relativenumber in insert",
    callback = function()
        if vim.o.number then
            vim.opt.relativenumber = false
        end
    end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
    desc = "relativenumber in non-insert",
    callback = function()
        if vim.o.number then
            vim.opt.relativenumber = true
        end
    end,
})

vim.api.nvim_create_autocmd('FocusGained', {
    desc = "Copy from clipboard on FocusGained",
    callback = function()
        vim.fn.setreg("0", vim.fn.getreg("+"))
        vim.fn.setreg("", vim.fn.getreg("+"))
    end,
})

vim.api.nvim_create_autocmd("LspProgress", {
    desc = "Show LSP Progress on cmdline",
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        if vim.fn.mode():find('c') == nil and vim.api.nvim_buf_get_name(0) ~= "cmdline" then
            if ev.data.params.value.kind == "end" then
                vim.api.nvim_echo({ { "" } }, false, {})
                return
            end
            vim.api.nvim_echo({ { vim.lsp.status() } }, false, {})
        end
    end,
})

-- set diagnotic signs
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
        },
    },
    severity_sort = true,
})
