vim.api.nvim_create_user_command("W", "noautocmd w", {})

vim.api.nvim_create_autocmd('InsertLeave', {
    desc = "refresh codelens",
    callback = function()
        vim.lsp.codelens.refresh({ bufnr = 0 })
    end,
})
