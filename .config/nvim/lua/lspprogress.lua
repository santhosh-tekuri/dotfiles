local ns = vim.api.nvim_create_namespace("lspprogress")

vim.api.nvim_create_autocmd("LspProgress", {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        if ev.data.params.value.kind == "end" then
            return
        end
        local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
        if wininfo.topline == 0 then
            return
        end
        vim.api.nvim_buf_set_extmark(0, ns, wininfo.botline - 1, 0, {
            virt_text = { { vim.lsp.status(), "Normal" } },
            virt_text_pos = "right_align",
            strict = false,
        })
    end,
})
