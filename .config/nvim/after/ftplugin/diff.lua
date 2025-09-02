local function node_at(line)
    return vim.treesitter.get_node { pos = { line - 1, 0 } }
end

local function select_lines(from, to)
    if vim.fn.mode():find('v') ~= nil then
        vim.cmd('normal! ' .. from .. 'GoV' .. to .. 'G')
    else
        vim.cmd('normal! ' .. from .. 'GV' .. to .. 'G')
    end
end

function Select_change()
    local line = vim.fn.line('.')
    local function is_change()
        local type = node_at(line):type()
        return type == "addition" or type == "deletion"
    end

    local last = vim.fn.line('$')
    if is_change() then
        while line > 1 do
            line = line - 1
            if not is_change() then
                line = line + 1
                break
            end
        end
    else
        while line ~= last do
            line = line + 1
            if is_change() then
                break
            end
        end
    end
    if not is_change() then
        return
    end
    local from = line
    while line ~= last do
        line = line + 1
        if not is_change() then
            select_lines(from, line - 1)
            break
        end
    end
end

function Select_node(type)
    local line = vim.fn.line('.')
    local function ancestor()
        local node = node_at(line)
        while node ~= nil and node:type() ~= type do
            node = node:parent()
        end
        return node
    end
    local last = vim.fn.line('$')
    while true do
        local hunk = ancestor()
        if hunk ~= nil then
            local srow = hunk:start()
            local frow = hunk:end_()
            select_lines(srow + 1, frow)
            break
        end
        if line == last then
            break
        end
        line = line + 1
    end
end

local function textobj(ltr, func)
    local rhs = ':<c-u>lua ' .. func .. '<cr>'
    local opts = { noremap = true, silent = true }
    for _, mode in ipairs({ 'x', 'o' }) do
        vim.api.nvim_buf_set_keymap(0, mode, 'i' .. ltr, rhs, opts)
        vim.api.nvim_buf_set_keymap(0, mode, 'a' .. ltr, rhs, opts)
    end
end

textobj('c', 'Select_change()');
textobj('h', 'Select_node("hunk")');
textobj('f', 'Select_node("block")');
