require("opts")
require("keymaps")
require("usercmds")
require("autocmds")
require("textobjs")
require("stc")
require("term")
require("worddiff")

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
    require("specs.quickfix"),
    require("specs.picker"),
    require("specs.cmdline"),
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
    { "folke/snacks.nvim", opts = { picker = { enabled = true } } }
}
