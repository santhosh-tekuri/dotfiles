-- move current line up/down
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==")

-- move selected lines up/down
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv")

-- system clipboard
vim.keymap.set({ 'n', 'v' }, ' y', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set('n', ' Y', '"+Y', { desc = "Copy to system clipboard" })
vim.keymap.set({ 'n', 'v' }, ' p', '"+p', { desc = "Paste clipboard after selection" })
vim.keymap.set({ 'n', 'v' }, ' P', '"+P', { desc = "Paste clipboard before selection" })

-- use <space>w for window commands
vim.keymap.set('n', ' w', '<c-w>', { remap = false })

-- retain selection after indent ('gv' highlights previous selection)
vim.keymap.set('v', '>', '>gv', { remap = false })
vim.keymap.set('v', '<', '<gv', { remap = false })

local function close_floats()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then          -- is_floating_window?
            vim.api.nvim_win_close(win, false) -- do not force
        end
    end
end
vim.keymap.set('n', '<esc>', close_floats, { desc = "close floating windows" })
