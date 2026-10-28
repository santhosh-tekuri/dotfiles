vim.api.nvim_create_autocmd("BufHidden", {
    desc = "Delete welcome buffer when hidden",
    callback = function(ev)
        if ev.buf == 1 then
            vim.schedule(function()
                if vim.bo.buftype == "terminal" then
                    return
                end
                vim.api.nvim_del_autocmd(ev.id)
                if vim.api.nvim_buf_is_valid(1)
                    and vim.api.nvim_buf_get_name(1) == ""
                    and vim.bo[1].filetype == ""
                    and not vim.bo[1].modified then
                    vim.api.nvim_buf_delete(1, { force = true })
                end
            end)
        end
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Format on save",
    group = vim.api.nvim_create_augroup("Format", {}),
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
    desc = "Show LSP Progress at bottom right corner",
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        if vim.fn.getcmdtype() ~= "" then
            return -- cmdline is in focus
        end
        --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        local value = ev.data.params.value
        if type(value) ~= "table" then
            return
        end
        if value.kind == "end" then
            vim.api.nvim_echo({}, false, {});
        else
            vim.api.nvim_echo({
                { (" %3d%% "):format(value.percentage or 100), "WarningMsg" },
                { value.title },
            }, false, {})
        end
    end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufModifiedSet', 'DiagnosticChanged' }, {
    desc = "show file name with diagnostic hint in ruler",
    callback = function()
        local function group(bufnr)
            for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
                local n = #vim.diagnostic.count(bufnr, { severity = vim.diagnostic.severity[name] })
                if n > 0 then
                    return '%#DiagnosticVirtualText' .. string.lower(name) .. "#"
                end
            end
            return ""
        end
        local s = "%=" .. group(nil) .. "%t"
        s = s .. (vim.bo.modified and '*' or ' ')
        s = s .. "%0* %7(%l,%c%)"
        s = "%60(" .. s .. "%)"
        if vim.o.rulerformat ~= s then
            vim.opt.rulerformat = s
        end
    end
})
