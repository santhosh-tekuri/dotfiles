-- editable command line

vim.pack.add { "https://github.com/smilhey/ed-cmd.nvim" }

require("ed-cmd").setup({
    cmdline = {
        keymaps = { edit = "<c-]>", close = '<esc>' }
    }
})
