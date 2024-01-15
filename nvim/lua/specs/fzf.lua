local spec = {
    "ibhagwan/fzf-lua",
}

function spec.config()
    local fzf = require("fzf-lua")
    fzf.setup({})

    vim.keymap.set('n', ' f', fzf.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', fzf.buffers, { desc = "Open buffer picker" })
end

return spec
