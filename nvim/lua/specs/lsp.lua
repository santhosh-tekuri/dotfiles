-- lsp setup

local spec = {
    "williamboman/mason.nvim",
}

function spec.config()
    require("mason").setup()
    for _, f in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
        vim.lsp.enable(vim.fn.fnamemodify(f, ':t:r'))
    end
end

return spec
