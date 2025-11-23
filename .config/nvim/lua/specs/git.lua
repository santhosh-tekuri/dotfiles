local spec = {
    "santhosh-tekuri/git.nvim",
    -- dir = "~/gh/santhosh-tekuri/git.nvim",
}

function spec.config()
    vim.keymap.set('n', ' g', "<cmd>GitStatus<cr>")
end

return spec
