vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true   -- convert tabs to spaces
vim.opt.shiftwidth = 4     -- no of spaces inserted for each indentation
vim.opt.tabstop = 4        -- no of spaces inserted for tab
vim.opt.signcolumn = "yes" -- always show signcolumn
vim.opt.wrap = false
vim.opt.laststatus = 3     -- single statusline for all splits

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- show whitespace using :set list
vim.opt.listchars:append("space:.")
vim.opt.listchars:append("trail:.")
vim.opt.listchars:append("tab:>-")

-- use <space>w for window commands
vim.keymap.set('n', ' w', '<c-w>', { remap = false })

-- retain selection after indent ('gv' highlights previous selection)
vim.keymap.set('v', '>', '>gv', { remap = false })
vim.keymap.set('v', '<', '<gv', { remap = false })

vim.keymap.set('n', '<esc>', '<c-w>o', { desc = "close other windows" })

-- system clipboard
vim.keymap.set({ 'n', 'v' }, ' y', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ 'n', 'v' }, ' p', '"+p', { desc = "Paste clipboard after selection" })
vim.keymap.set({ 'n', 'v' }, ' P', '"+P', { desc = "Paste clipboard before selection" })

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
    require("specs.notify"),
    require("specs.gitsigns"),
    require("specs.fzf"),
    -- require("specs.telescope"),
    require("specs.treesitter"),
    require("specs.treesitter_textobjs"),
    require("specs.lspconfig"),
    require("specs.cmp"),
    require("specs.lspsignature"),
    require("specs.lspprogress"),
    require("specs.comment"),
    require("specs.sandwich"),
    --require("specs.smarttab"),
    require("specs.minimove"),
    require("specs.lualine"),
    require("specs.trouble"),
    require("specs.colorizer"),
    require("specs.whichkey"),
    require("specs.textobj_line"),
}

vim.cmd.colorscheme "kanagawa"
