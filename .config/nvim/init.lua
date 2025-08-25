require("opts")
require("keymaps")
require("usercmds")
require("autocmds")
require('quickfix')
require("textobjs")
require("term")

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
    require("specs.cmdline"),
    require("specs.snacks"),
    require("specs.oil"),
    require("specs.gitsigns"),
    require("specs.treesitter"),
    require("specs.autotag"),
    require("specs.lsp"),
    -- require("specs.cmp"),
    require("specs.blink"),
    require("specs.surround"),
    require("specs.colorizer"),
    require("specs.urlopen"),
    require("specs.coverage"),
    require("specs.autopairs"),
    require("specs.registers"),
}
