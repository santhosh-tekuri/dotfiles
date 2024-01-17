vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 4 -- no of spaces inserted for each indentation
vim.opt.tabstop = 4 -- no of spaces inserted for tab
vim.opt.signcolumn = "yes" -- always show signcolumn
vim.opt.wrap = false

-- system clipboard
vim.keymap.set('n', ' y', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set('n', ' p', '"+p', { desc = "Paste clipboard after selection" })
vim.keymap.set('n', ' P', '"+P', { desc = "Paste clipboard before selection" })

-- goto motions
vim.keymap.set({'n', 'v'}, 'gl', '$', { desc = "Goto line end" })
vim.keymap.set({'n', 'v'}, 'gh', '0', { desc = "Goto line start" })
vim.keymap.set({'n', 'v'}, 'gs', '^', { desc = "Goto first non-blank in line" })
vim.keymap.set({'n', 'v'}, 'ge', 'G', { desc = "Goto last line" })
vim.keymap.set({'n', 'v'}, 'gt', 'H', { desc = "Goto window top" })
vim.keymap.set({'n', 'v'}, 'gc', 'M', { desc = "Goto window center" })
vim.keymap.set({'n', 'v'}, 'gb', 'L', { desc = "Goto window bottom" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- load plugin specs
require("lazy").setup({
    require("specs.gitsigns"),
    require("specs.fzf"),
    require("specs.treesitter"),
    require("specs.lspconfig"),
    require("specs.cmp"),
    require("specs.whichkey"),
    require("specs.sandwich"),
    require("specs.minimove"),
    require("specs.kanagawa"),
})

vim.cmd.colorscheme "kanagawa-wave"

