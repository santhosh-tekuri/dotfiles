local M = {}

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

function M.quickfix_text(info)
    local list
    local what = { id = info.id, items = 1, qfbufnr = 1 }
    if info.quickfix == 1 then
        list = vim.fn.getqflist(what)
    else
        list = vim.fn.getloclist(info.winid, what)
    end

    local ttt = {}
    for _, item in ipairs(list.items) do
        local tt = { { '  ', 'qfText' } }
        if item.bufnr == 0 then
            table.insert(tt, { item.text, 'qfText' })
        else
            table.insert(tt, { '' .. item.lnum .. ': ', 'qfLineNr' })
            local text = item.text:match "^%s*(.-)%s*$" -- trim item.text
            local hl = typeHilights[item.type] or 'qfText'
            table.insert(tt, { text, hl })
        end
        table.insert(ttt, tt)
    end

    vim.schedule(function()
        apply_highlights(list.qfbufnr, ttt)
    end)
    return get_lines(ttt)
end

vim.o.quickfixtextfunc = "v:lua.require'quickfix'.quickfix_text"

---------------------------------------------------------------------------------------------

local function add_virt_lines()
    if vim.bo[0].buftype ~= 'quickfix' then
        return
    end
    local list = vim.fn.getqflist({ id = 0, winid = 1, qfbufnr = 1, items = 1 })
    vim.api.nvim_buf_clear_namespace(list.qfbufnr, ns, 0, -1)
    local lastfname = ''
    for i, item in ipairs(list.items) do
        local fname = vim.fn.bufname(item.bufnr)
        fname = vim.fn.fnamemodify(fname, ':p:.')
        if fname ~= "" and fname ~= lastfname then
            lastfname = fname
            vim.api.nvim_buf_set_extmark(list.qfbufnr, ns, i - 1, 0, {
                virt_lines = { { { fname .. ":", "qfFilename" } } },
                virt_lines_above = true,
                strict = false,
            })
        end
    end
end

vim.api.nvim_create_autocmd('BufReadPost', {
    desc = "filename as virt_lines",
    callback = add_virt_lines,
})

---------------------------------------------------------------------------------------------

-- workaround for:
--      cannot scroll to see virtual line before first line
--      see https://github.com/neovim/neovim/issues/16166
local function scrollup()
    if vim.bo[0].buftype ~= 'quickfix' then
        return
    end
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    if row == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>', true, false, true), 'm', true)
    end
end

vim.api.nvim_create_autocmd('CursorMoved', {
    desc = "scroll up beyond first line",
    callback = scrollup,
})

return M
