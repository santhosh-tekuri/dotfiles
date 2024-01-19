local spec = {
    "ibhagwan/fzf-lua",
}

function spec.config()
    local fzf = require("fzf-lua")
    fzf.setup({
        winopts = {
            width = 0.9,
            col = 0.5,
            preview = {
                vertial = 'down:50%',
                horizontal = 'right:50%',
            }
        },
    })

    vim.keymap.set('n', ' f', fzf.files, { desc = "Open file picker" })
    vim.keymap.set('n', ' b', fzf.buffers, { desc = "Open buffer picker" })
    vim.keymap.set('n', ' /', fzf.live_grep, { desc = "Global search in workspace folder" })
end

return spec
