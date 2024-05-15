-- ui for lsp progress messages

return {
    "j-hui/fidget.nvim",
    opts = {
        progress = {
            display = {
                done_ttl = 0, -- dismiss immediately after completion
            }
        },
        notification = {
            override_vim_notify = true,
        }
    },
}
