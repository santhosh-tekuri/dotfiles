local function select_lines(from, to)
    vim.cmd('normal! ' .. from .. 'GV' .. to .. 'G')
end

local function select_region(srow, scol, erow, ecol)
    vim.fn.cursor(srow, scol)
    vim.cmd("normal! v")
    vim.fn.cursor(erow, ecol)
end

local function textobj(ltr, func)
    local opts = { noremap = true, silent = true }
    vim.keymap.set({ 'x', 'o' }, 'i' .. ltr, function()
        vim.cmd("normal! ")
        func(false)
    end, opts)
    vim.keymap.set({ 'x', 'o' }, 'a' .. ltr, function()
        vim.cmd("normal! ")
        func(true)
    end, opts)
end

-------------------------------------------------------------------------------

local function select_line(around)
    if around then
        vim.cmd("normal! 0v$")
    else
        vim.cmd("normal! ^vg_")
    end
end

textobj("l", select_line)

-------------------------------------------------------------------------------

local function select_entire(around)
    vim.cmd("normal! m'")
    if around then
        vim.cmd("keepjumps normal gg0vG$")
    else
        -- vim.cmd("keepjumps normal! gg0\r/^.\rvG$?^.\r")
        -- the above line works but records searchs
        vim.cmd("keepjumps normal! gg0")
        vim.fn.search('^.', 'cW')
        local from = vim.api.nvim_win_get_cursor(0)
        vim.cmd("keepjumps normal G$")
        vim.fn.search('^.', 'bcW')
        local to = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, from)
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(0, to)
    end
end

textobj("e", select_entire)

-------------------------------------------------------------------------------

local function select_expression()
    local node = vim.treesitter.get_node()
    if node == nil then
        return
    end
    local srow, scol = node:start()
    while true do
        local p = node:parent()
        if p == nil then
            break
        end
        local prow, pcol = p:start()
        if prow ~= srow or pcol ~= scol then
            break
        end
        node = p
    end
    local erow, ecol = node:end_()
    select_region(srow + 1, scol + 1, erow + 1, ecol)
end

textobj("x", select_expression)

-------------------------------------------------------------------------------

local function get_indent()
    local line = vim.fn.line('.')
    local indent = vim.fn.indent(line)
    if indent > 0 or #vim.fn.getline(line) > 0 then
        return indent
    end

    local i = 1
    while line - i > 0 do
        indent = vim.fn.indent(line - i)
        if indent > 0 or #vim.fn.getline(line) > 0 then
            return indent
        end
        i = i + 1
    end

    i = 1
    local last = vim.fn.line('$')
    while line + 1 <= last do
        indent = vim.fn.indent(line + i)
        if indent > 0 or #vim.fn.getline(line) > 0 then
            return indent
        end
        i = i + 1
    end

    return 0
end

local function select_indent(around)
    local indent = get_indent()
    vim.print(indent)
    local line = vim.fn.line('.')

    local from = line
    while from - 1 > 0 do
        local ind = vim.fn.indent(from - 1)
        if ind == 0 and indent > 0 then
            if #vim.fn.getline(from - 1) > 0 then
                break
            end
        elseif ind < indent then
            break
        end
        from = from - 1
    end

    local to = line
    local last = vim.fn.line('$')
    while to + 1 <= last do
        local ind = vim.fn.indent(to + 1)
        if ind == 0 and indent > 0 then
            if #vim.fn.getline(to + 1) > 0 then
                break
            end
        elseif ind < indent then
            break
        end
        to = to + 1
    end

    if around then
        if from ~= 1 then
            from = from - 1
        end
        if vim.bo.filetype ~= "python" and to ~= last then
            to = to + 1
        end
    end

    select_lines(from, to)
end

textobj("i", select_indent)

-------------------------------------------------------------------------------

local function select_toplevel(around)
    local line, last = vim.fn.line('.'), vim.fn.line('$')

    local from = line
    while true do
        if from == 0 then
            break
        end
        if vim.fn.getline(from) ~= '' and vim.fn.indent(from) == 0 and vim.fn.getline(from - 1) == '' then
            break
        end
        from = from - 1
    end

    local to = line
    while true do
        if to == last then
            break
        end
        if vim.fn.getline(to) == '' and vim.fn.indent(to + 1) == 0 and vim.fn.getline(to + 1) ~= '' then
            break
        end
        to = to + 1
    end

    if not around then
        while to > line do
            if vim.fn.getline(to) ~= '' then
                break
            end
            to = to - 1
        end
    end

    select_lines(from, to)
end

textobj("P", select_toplevel)

-------------------------------------------------------------------------------

local function select_varsegment(around)
    local str = vim.fn.getline('.')
    local col = vim.fn.col('.')
    if not str:sub(col, col):match('[a-zA-Z0-9_]') then
        return
    end

    local scol = col
    while scol > 1 do
        local ch = str:sub(scol - 1, scol - 1)
        if not ch:match('[a-zA-Z0-9_]') then
            break
        end
        if ch == '_' then
            break
        end
        if ch:match('[a-z]') and str:sub(scol, scol):match('[A-Z]') then
            break
        end
        scol = scol - 1
    end

    local ecol = col
    while ecol < #str do
        local ch = str:sub(ecol + 1, ecol + 1)
        if not ch:match('[a-zA-Z0-9_]') then
            break
        end
        if ch == '_' then
            if around then
                ecol = ecol + 1
            end
            break
        end
        if ch:match('[A-Z]') and str:sub(scol, scol):match('[a-z]') then
            break
        end
        ecol = ecol + 1
    end

    local line = vim.fn.line('.')
    select_region(line, scol, line, ecol)
end

textobj("v", select_varsegment)
