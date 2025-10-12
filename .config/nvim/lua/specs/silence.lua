local spec = {
    "santhosh-tekuri/silence.nvim",
    -- dir = "~/gh/santhosh-tekuri/silence.nvim",
}

function spec.config()
    vim.cmd.colorscheme("silence")
end

return spec
