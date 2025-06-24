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

-- set diagnotic signs
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
    },
    severity_sort = true,
})

-- options for vim.lsp.hover floating window (for golang popup is too wide)
local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover({
        max_width = 80,
    })
end
