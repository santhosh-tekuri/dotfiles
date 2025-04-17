local nsid = vim.api.nvim_create_namespace("filename")

local function render()
    local filename = vim.fn.expand('%:t')
    local modified = vim.bo[0].modified
    filename = filename .. (modified and '*' or ' ') .. ' '

    -- group based on diagnostic
    local group = "Text"
    for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
        local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[name] })
        if n > 0 then
            group = 'DiagnosticVirtualText' .. string.lower(name)
            break
        end
    end

    return { filename, group }
end

local function show()
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
    vim.api.nvim_buf_clear_namespace(0, nsid, 0, -1)
    local filename = vim.fn.expand('%:t')
    local modified = vim.bo[0].modified
    filename = filename .. (modified and '*' or ' ')
    vim.api.nvim_buf_set_extmark(0, nsid, wininfo.topline - 1, 0, {
        virt_text = { render() },
        virt_text_pos = "right_align",
        virt_lines_above = true,
        strict = false,
    })
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufModifiedSet', 'WinScrolled' }, {
    desc = "show floating filename",
    callback = show,
})
