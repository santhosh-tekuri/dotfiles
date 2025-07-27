local ns = vim.api.nvim_create_namespace("winline")

local function virt_text()
    if not vim.bo[0].buflisted then
        return {}
    end
    local file = vim.fn.expand('%:t')
    if file == '' then
        if vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= '' then
            return {}
        end
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
        return "NormalFloat"
    end
    return { { ' ', group(nil) }, { file, group(0) } }
end

local function show()
    if vim.api.nvim_win_get_config(0).relative ~= '' then
        return
    end
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
    if wininfo.topline == 0 then
        return
    end
    local text = virt_text()
    if #text == 0 then
        return
    end
    vim.api.nvim_buf_set_extmark(0, ns, wininfo.topline - 1, 0, {
        virt_text = text,
        virt_text_pos = "right_align",
        strict = false,
    })
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufModifiedSet', 'WinScrolled', 'DiagnosticChanged' }, {
    desc = "show winline",
    callback = show,
})
