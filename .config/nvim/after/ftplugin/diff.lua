function Select_change()
    local function is_change()
        local type = vim.treesitter.get_node():type()
        return type == "addition" or type == "deletion"
    end

    local last = vim.fn.line('$')
    if is_change() then
        while vim.fn.line('.') > 1 do
            vim.cmd("-")
            if not is_change() then
                vim.cmd("+")
                break
            end
        end
    else
        while vim.fn.line(".") ~= last do
            vim.cmd("+")
            if is_change() then
                break
            end
        end
    end
    if not is_change() then
        return
    end
    vim.cmd('normal! 0V')
    while vim.fn.line(".") ~= last do
        vim.cmd("+")
        if not is_change() then
            vim.cmd("-")
            break
        end
    end
end

local function select_lines(from, to)
    if vim.fn.mode():find('v') ~= nil then
        vim.cmd('normal! ' .. from .. 'GoV' .. to .. 'G')
    else
        vim.cmd('normal! ' .. from .. 'GV' .. to .. 'G')
    end
end

function Select_node(type)
    local function get_node()
        local node = vim.treesitter.get_node()
        while node ~= nil and node:type() ~= type do
            node = node:parent()
        end
        return node
    end
    local last = vim.fn.line('$')
    while true do
        local hunk = get_node()
        if hunk ~= nil then
            local srow = hunk:start()
            local frow = hunk:end_()
            select_lines(srow + 1, frow)
            break
        end
        if vim.fn.line('.') == last then
            break
        end
        vim.cmd('+')
    end
end

for _, mode in ipairs({ 'x', 'o' }) do
    vim.api.nvim_set_keymap(mode, 'ic', ':<c-u>lua Select_change()<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'ac', ':<c-u>lua Select_change()<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'ih', ':<c-u>lua Select_node("hunk")<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'ah', ':<c-u>lua Select_node("hunk")<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'if', ':<c-u>lua Select_node("block")<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'af', ':<c-u>lua Select_node("block")<cr>', { noremap = true, silent = true })
end
