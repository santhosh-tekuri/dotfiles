require("opts")
require("keymaps")
require("commands")
require("misc")
require('insjump')
require('winline')
require('quickfix')

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
vim.opt.runtimepath:prepend(lazypath)

vim.cmd.colorscheme("santhosh")

-- load plugin specs
require("lazy").setup {
    -- require("specs.fzf"),
    -- require("specs.telescope"),
    require("specs.snacks"),
    require("specs.oil"),
    require("specs.fidget"),
    require("specs.gitsigns"),
    require("specs.treesitter"),
    require("specs.treesitter_textobjs"),
    require("specs.autotag"),
    require("specs.lsp"),
    -- require("specs.conform"),
    -- require("specs.cmp"),
    require("specs.blink"),
    require("specs.surround"),
    require("specs.colorizer"),
    -- require("specs.whichkey"),
    require("specs.textobj"),
    require("specs.urlopen"),
    require("specs.coverage"),
    require("specs.autopairs"),
}
