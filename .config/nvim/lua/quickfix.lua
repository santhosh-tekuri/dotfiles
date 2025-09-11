local ns = vim.api.nvim_create_namespace("qflist")

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
            fname = vim.fn.fnamemodify(fname, ':p:.')
            table.insert(tt, { fname, "qfFilename" })
            if item.lnum == 0 then
                table.insert(tt, { " ", "Default" })
                table.insert(tt, { item.text, typeHilights[item.type] or 'qfText' })
            else
                table.insert(tt, { ":" .. item.lnum, "qfLineNr" })
                table.insert(tt, { " ", "Default" })
                if item.end_col ~= 0 and item.end_lnum == item.lnum then
                    table.insert(tt, { item.text:sub(1, item.col - 1), 'qfText' })
                    table.insert(tt,
                        { item.text:sub(item.col, item.end_col - 1), typeHilights[item.type] or typeHilights["W"] })
                    table.insert(tt, { item.text:sub(item.end_col), 'qfText' })
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
