vim.g.mapleader = " "

vim.keymap.set("n", "gh", "^", { desc = "to first non-blank char of the line" })
vim.keymap.set("n", "gl", "g_", { desc = "to last non-blank char of the line" })

-- move current line up/down
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==")

-- move selected lines up/down
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv")

-- system clipboard
vim.keymap.set({ 'n', 'v' }, ' p', '"+p', { desc = "Paste clipboard after cursor" })
vim.keymap.set({ 'n', 'v' }, ' P', '"+P', { desc = "Paste clipboard before cursor" })

-- use <space>w for window commands
vim.keymap.set('n', ' w', '<c-w>', { remap = false })

-- retain selection after indent ('gv' highlights previous selection)
vim.keymap.set('v', '>', '>gv', { remap = false })
vim.keymap.set('v', '<', '<gv', { remap = false })

vim.keymap.set('n', '<esc>', function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative == "win" then       -- is_floating_window?
            vim.api.nvim_win_close(win, false) -- do not force
        end
    end
end, { desc = "close floating windows" })

vim.keymap.set("i", "<C-L>", function()
    local node = vim.treesitter.get_node()
    if node ~= nil then
        local row, col = node:end_()
        pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
    end
end, { desc = "jump to end of current treesitter node" })

-- `<leader>'{char}` opens file containing mark upper({char})
vim.keymap.set('n', "<leader>'", function()
    local char = vim.fn.getcharstr(-1)
    if char == "\27" then
        return -- got <esc>
    end
    local m = vim.api.nvim_get_mark(char:upper(), {})
    if m[4] ~= "" then
        vim.cmd.edit(m[4])
    end
end, { desc = "open buffer with mark" })

vim.keymap.set('n', 'dq', function()
    if vim.wo.diff then
        vim.cmd('q')
        vim.cmd('q')
    end
end, { desc = "close buffers in diff split" })

-- lsp related keymaps and config
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local function opts(desc)
            return { buffer = ev.buf, desc = desc }
        end
        vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, opts("Perform code action"))
        vim.keymap.set('n', '<leader>n', vim.lsp.buf.rename, opts("Rename symbol"))
        local function with_maxwidth(func)
            return function()
                func({ max_width = 80 })
            end
        end
        vim.keymap.set({ 'n', 'v' }, 'K', with_maxwidth(vim.lsp.buf.hover), opts("Show docs for item under cursor"))
        vim.keymap.set({ 'n', 'i' }, '<c-k>', with_maxwidth(vim.lsp.buf.signature_help), opts("Show signature"))
        vim.keymap.set('n', '<leader>l', vim.lsp.codelens.run, opts("Perform codelens"))

        vim.keymap.set('n', '<leader>k', function()
            if vim.diagnostic.config().virtual_lines then
                vim.diagnostic.config({ virtual_lines = false })
                vim.api.nvim_clear_autocmds({ group = "hideDiag" })
            else
                vim.diagnostic.config({ virtual_lines = { current_line = true } })
                vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
                    group = vim.api.nvim_create_augroup("hideDiag", { clear = true }),
                    callback = function()
                        vim.diagnostic.config({ virtual_lines = false })
                        vim.api.nvim_clear_autocmds({ group = "hideDiag" })
                    end,
                    buffer = 0,
                })
            end
        end, opts("toggle diagnostic for current line"))

        -- setup codelens
        vim.lsp.codelens.refresh({ bufnr = 0 })
        vim.api.nvim_create_autocmd('InsertLeave', {
            desc = "refresh codelens",
            callback = function()
                vim.lsp.codelens.refresh({ bufnr = 0 })
            end,
            buffer = 0,
        })
    end,
})
