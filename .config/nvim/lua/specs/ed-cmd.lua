-- editable command line

require("ed-cmd").setup({
    cmdline = {
        keymaps = { edit = "<c-]>", close = '<esc>' }
    }
})
