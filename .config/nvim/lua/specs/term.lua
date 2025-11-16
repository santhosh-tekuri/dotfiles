local spec = {
    "santhosh-tekuri/term.nvim",
    -- dir = "~/gh/santhosh-tekuri/term.nvim",
}

function spec.config()
    vim.keymap.set({ "n", "t" }, "<c-/>", "<CMD>ToggleTerm<cr>")
    vim.keymap.set({ "n", "t" }, "<c-s-/>", "<CMD>PickTerm<cr>")
    vim.keymap.set("n", "<leader>q", "<CMD>SafeQuit<cr>")
    vim.keymap.set('n', '<leader>g', "<cmd>RunCmd! lazygit<cr>", { desc = "launch lazygit" })
end

return spec
