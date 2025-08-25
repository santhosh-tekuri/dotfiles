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

local lspprogress_buf = nil
vim.api.nvim_create_autocmd("LspProgress", {
    desc = "Show LSP Progress at bottom right corner",
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        local value = ev.data.params.value
        if type(value) ~= "table" then
            return
        end
        if value.kind == "end" then
            if lspprogress_buf ~= nil then
                vim.api.nvim_buf_delete(lspprogress_buf, {})
                lspprogress_buf = nil
            end
            return
        end
        local width = 35
        if lspprogress_buf == nil then
            lspprogress_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = lspprogress_buf })
            local winid = vim.api.nvim_open_win(lspprogress_buf, false, {
                relative = "editor",
                row = vim.o.lines - 1,
                col = vim.o.columns - width,
                width = width,
                height = 1,
                style = "minimal",
                focusable = false,
            })
            vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = winid })
        end
        local msg = ("%3d%%: %s %s"):format(value.percentage or 100, value.title or "", value.message or "")
        msg = ("%" .. width .. "s"):format(msg)
        vim.api.nvim_buf_set_lines(lspprogress_buf, 0, -1, false, { msg })
    end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufModifiedSet', 'DiagnosticChanged' }, {
    desc = "show file name with diagnostic hint in ruler",
    callback = function()
        if not vim.bo.buflisted then
            return
        end
        local function group(bufnr)
            for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
                local n = #vim.diagnostic.count(bufnr, { severity = vim.diagnostic.severity[name] })
                if n > 0 then
                    return '%#DiagnosticVirtualText' .. string.lower(name) .. "#"
                end
            end
            return ""
        end
        local s = "%l,%c%="
        s = s .. group(nil) .. "%t"
        s = s .. (vim.bo.modified and '*' or ' ')
        s = "%36(" .. s .. "%)"
        if vim.o.rulerformat ~= s then
            vim.opt.rulerformat = s
        end
    end
})
