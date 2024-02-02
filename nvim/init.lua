vim.opt.number = true         -- show line number for each line
vim.opt.relativenumber = true -- show relative line number for each line
vim.opt.termguicolors = true  -- enable RGB colors
vim.opt.expandtab = true      -- convert tabs to spaces
vim.opt.shiftwidth = 4        -- no of spaces inserted for each indentation
vim.opt.tabstop = 4           -- no of spaces inserted for tab
vim.opt.signcolumn = "yes"    -- always show signcolumn
vim.opt.wrap = false          -- disable line wrap
vim.opt.laststatus = 3        -- single statusline for all splits
vim.opt.splitbelow = true     -- put new window below the split
vim.opt.splitright = true     -- put new window right to the split
vim.opt.inccommand = "split"  -- show substitute preview in split

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- show whitespace using :set list
vim.opt.listchars = { space = '.', tab = '>-', trail = '.' }

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

-- system clipboard
vim.keymap.set({ 'n', 'v' }, ' y', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set('n', ' Y', '"+Y', { desc = "Copy to system clipboard" })
vim.keymap.set({ 'n', 'v' }, ' p', '"+p', { desc = "Paste clipboard after selection" })
vim.keymap.set({ 'n', 'v' }, ' P', '"+P', { desc = "Paste clipboard before selection" })

-- move current line up/down
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==")

-- move selected lines up/down
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv")

-- disable virtual text for diagnostics
vim.diagnostic.config({ virtual_text = false })

-- highlight selection on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Hightlight selection on yank",
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 600 })
    end,
})

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- load plugin specs
require("lazy").setup {
    require("specs.kanagawa"),
    require("specs.fidget"),
    require("specs.gitsigns"),
    -- require("specs.fzf"),
    require("specs.telescope"),
    require("specs.treesitter"),
    require("specs.treesitter_textobjs"),
    require("specs.lspconfig"),
    require("specs.cmp"),
    require("specs.lspsignature"),
    require("specs.comment"),
    require("specs.surround"),
    --require("specs.smarttab"),
    require("specs.lualine"),
    require("specs.trouble"),
    require("specs.colorizer"),
    require("specs.whichkey"),
    require("specs.textobj_line"),
    require("specs.textobj_entire"),
    require("specs.autopairs"),
}
