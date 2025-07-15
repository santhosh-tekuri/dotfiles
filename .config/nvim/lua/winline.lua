local ns = vim.api.nvim_create_namespace("winline")

local function lsp_progress()
    local percentage = nil
    for _, client in ipairs(vim.lsp.get_clients()) do
        --- @diagnostic disable-next-line:no-unknown
        for progress in client.progress do
            --- @cast progress {token: lsp.ProgressToken, value: lsp.LSPAny}
            local value = progress.value
            if type(value) == 'table' and value.kind then
                local message = value.message and (value.title .. ': ' .. value.message) or value.title
                if value.percentage then
                    percentage = math.max(percentage or 0, value.percentage)
                end
            end
        end
    end
    if percentage then
        return { string.format('%3d%% ', percentage), "Normal" }
    else
        return { "", "Normal" }
    end
end

local function virt_text()
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
    return { lsp_progress(), { ' ', group(nil) }, { file, group(0) } }
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

vim.api.nvim_create_autocmd({ 'LspProgress', 'BufWinEnter', 'BufModifiedSet', 'WinScrolled', 'DiagnosticChanged' }, {
    desc = "show winline",
    callback = show,
})
