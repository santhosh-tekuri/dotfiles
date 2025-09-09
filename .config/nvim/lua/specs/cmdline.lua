-- editable command line

local spec = { "smilhey/ed-cmd.nvim" }

function spec.config()
    require("ed-cmd").setup({
        cmdline = {
            keymaps = { close = '<esc>' }
        }
    })
end

return spec
