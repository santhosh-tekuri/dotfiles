local spec = {
    "ibhagwan/fzf-lua",
}

function spec.config()
    local fzf = require("fzf-lua")
    fzf.setup({})

    vim.keymap.set('n', ' f', fzf.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', fzf.buffers, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', fzf.live_grep, { desc = "Global search in workspace folder" })
end

return spec
