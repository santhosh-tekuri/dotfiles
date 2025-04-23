local ns = vim.api.nvim_create_namespace("winline")

local function virt_text()
    local file = vim.fn.expand('%:t')
    if file == '' then
        file = '[No Name]'
    end
    file = string.format('%s%s ', file, vim.bo[0].modified and '*' or ' ')
    local function group(bufnr)
        for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
            local n = #vim.diagnostic.count(bufnr, { severity = vim.diagnostic.severity[name] })
            if n > 0 then
                return 'DiagnosticVirtualText' .. string.lower(name)
            end
        end
        return "Text"
    end
    return { { ' ', group(nil) }, { file, group(0) } }
end

local function show()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
    vim.api.nvim_buf_set_extmark(0, ns, wininfo.topline - 1, 0, {
        virt_text = virt_text(),
        virt_text_pos = "right_align",
        virt_lines_above = true,
        strict = false,
    })
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufModifiedSet', 'WinScrolled', 'DiagnosticChanged' }, {
    desc = "show winline",
    callback = show,
})
