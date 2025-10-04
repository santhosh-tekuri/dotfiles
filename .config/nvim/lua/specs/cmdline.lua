-- editable command line

local spec = { "smilhey/ed-cmd.nvim" }

function spec.config()
    require("ed-cmd").setup({
        cmdline = {
            keymaps = { edit = "<c-]>", close = '<esc>' }
        }
    })
end

return spec
