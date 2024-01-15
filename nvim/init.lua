vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 4 -- no of spaces inserted for each indentation
vim.opt.tabstop = 4 -- no of spaces inserted for tab
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.signcolumn = "yes" -- always show signcolumn
vim.opt.wrap = false

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
    require("specs.catppuccin"),
    require("specs.gitsigns"),
    require("specs.fzf"),
    require("specs.treesitter"),
    require("specs.lspconfig"),
    require("specs.cmp"),
    require("specs.whichkey"),
})

