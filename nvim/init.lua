require("opts")
require("keymaps")
require("commands")

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
    require("specs.todo"),
    require("specs.treesitter"),
    require("specs.treesitter_textobjs"),
    require("specs.autotag"),
    -- require("specs.lspsignature"),
    require("specs.lspconfig"),
    require("specs.cmp"),
    require("specs.comment"),
    require("specs.surround"),
    --require("specs.smarttab"),
    -- require("specs.lualine"),
    require("specs.incline"),
    require("specs.trouble"),
    require("specs.colorizer"),
    require("specs.whichkey"),
    require("specs.textobj_line"),
    require("specs.textobj_entire"),
    require("specs.textobj_braces"),
    require("specs.textobj_comment"),
    require("specs.textobj_backticks"),
    require("specs.textobj_quotes"),
    require("specs.textobj_toplevel"),
    require("specs.textobj_variable_segment"),
    require("specs.autopairs"),
    require("specs.diffview"),
}
