local ns = vim.api.nvim_create_namespace("winline")

local function virt_text()
    local filename = vim.fn.expand('%:t')
    local modified = vim.bo[0].modified
    filename = filename .. (modified and '*' or ' ') .. ' '

    -- fetch priority diagnostic type
    local group = "Text"
    for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
        local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[name] })
        if n > 0 then
            group = 'DiagnosticVirtualText' .. string.lower(name)
            break
        end
    end

    return { { filename, group } }
end

local function show()
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
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
