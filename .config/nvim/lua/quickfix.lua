local ns = vim.api.nvim_create_namespace("qflist")

vim.api.nvim_set_hl(0, "qfMatch", { link = "Removed", default = true })

local function get_lines(ttt)
    local lines = {}
    for _, tt in ipairs(ttt) do
        local line = ''
        for _, t in ipairs(tt) do
            line = line .. t[1]
        end
        table.insert(lines, line)
    end
    return lines
end

local function apply_highlights(bufnr, ttt)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    for i, tt in ipairs(ttt) do
        local col = 0
        for _, t in ipairs(tt) do
            vim.hl.range(bufnr, ns, t[2], { i - 1, col }, { i - 1, col + #t[1] })
            col = col + #t[1]
        end
    end
end

local typeHilights = {
    E = 'DiagnosticSignError',
    W = 'DiagnosticSignWarn',
    I = 'DiagnosticSignInfo',
    N = 'DiagnosticSignHint',
    H = 'DiagnosticSignHint',
}

local function fileshorten(fname)
    if vim.fn.isabsolutepath(fname) == 0 then
        return fname
    end
    local name = vim.fn.fnamemodify(fname, ":.")
    if name == fname then
        name = vim.fn.fnamemodify(name, ":~")
    end
    return name
end

function QuickfixText(info)
    local list
    local what = { id = info.id, items = 1, qfbufnr = 1 }
    if info.quickfix == 1 then
        list = vim.fn.getqflist(what)
    else
        list = vim.fn.getloclist(info.winid, what)
    end

    local ttt = {}
    for _, item in ipairs(list.items) do
        local tt = {}
        if item.bufnr == 0 then
            table.insert(tt, { item.text, "qfText" })
        else
            local fname = vim.fn.bufname(item.bufnr)
            fname = fileshorten(fname)
            table.insert(tt, { fname, "qfFilename" })
            if item.lnum > 0 then
                table.insert(tt, { ":" .. item.lnum, "qfLineNr" })
                table.insert(tt, { " ", "Default" })
                local hl = typeHilights[item.type]
                if hl then
                    table.insert(tt, { item.text, hl })
                elseif item.end_col ~= 0 and item.end_lnum == item.lnum then
                    local matches = nil
                    if item.user_data and type(item.user_data) == 'table' then
                        matches = item.user_data.matches
                    end
                    if not matches then
                        if item.lnum and item.col and item.end_col then
                            if item.lnum > 0 and item.col > 0 and item.end_col > 0 then
                                matches = { { item.col, item.end_col } }
                            end
                        end
                    end
                    local from = 1
                    for _, m in ipairs(matches or {}) do
                        table.insert(tt, { item.text:sub(from, m[1] - 1), 'qfText' })
                        table.insert(tt, { item.text:sub(m[1], m[2]), "qfMatch" })
                        from = m[2] + 1
                    end
                    if from <= #item.text then
                        table.insert(tt, { item.text:sub(from), 'qfText' })
                    end
                else
                    table.insert(tt, { item.text, typeHilights[item.type] or 'qfText' })
                end
            end
        end
        table.insert(ttt, tt)
    end
    vim.schedule(function()
        apply_highlights(list.qfbufnr, ttt)
    end)
    return get_lines(ttt)
end

vim.o.quickfixtextfunc = "v:lua.QuickfixText"
