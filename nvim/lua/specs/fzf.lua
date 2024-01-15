local spec = {
    "ibhagwan/fzf-lua",
}

function spec.config()
    local fzf = require("fzf-lua")
    fzf.setup({})

    vim.keymap.set('n', ' f', fzf.files, {})
    vim.keymap.set('n', ' b', fzf.buffers, {})
end

return spec
