local M = {}

local ns = vim.api.nvim_create_namespace("qflist")
local function apply_highlights(bufnr, highlights)
    for _, hl in ipairs(highlights) do
        vim.hl.range(
            bufnr,
            ns,
            hl.group,
            { hl.line, hl.col },
            { hl.line, hl.end_col }
        )
    end
end

function M.quickfix_text(info)
    local list
    if info.quickfix == 1 then
        list = vim.fn.getqflist({ id = info.id, items = 1, qfbufnr = 1 })
    else
        list = vim.fn.getloclist(info.winid, { id = info.id, items = 1, qfbufnr = 1 })
    end

    local lines = {}
    local highlights = {}
    for i, item in ipairs(list.items) do
        local line = '  ' .. item.lnum .. ': '
        local end_col = #line
        table.insert(highlights, { group = "qfLineNr", line = i - 1, col = 0, end_col = end_col })
        line = line .. item.text:match "^%s*(.-)%s*$" -- trim item.text
        table.insert(highlights, { group = "qfText", line = i - 1, col = end_col, end_col = #line })
        table.insert(lines, line)
    end

    vim.schedule(function()
        apply_highlights(list.qfbufnr, highlights)
    end)
    return lines
end

vim.o.quickfixtextfunc = "v:lua.require'quickfix'.quickfix_text"

---------------------------------------------------------------------------------------------

local function add_virt_lines()
    if vim.bo[0].buftype ~= 'quickfix' then
        return
    end
    local list = vim.fn.getqflist({ id = 0, winid = 1, qfbufnr = 1, items = 1 })
    vim.print(list.qfbufnr)
    vim.api.nvim_buf_clear_namespace(list.qfbufnr, ns, 0, -1)
    local lastfname = ''
    for i, item in ipairs(list.items) do
        local fname = vim.fn.bufname(item.bufnr)
        fname = vim.fn.fnamemodify(fname, ':p:.')
        if fname ~= lastfname then
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
