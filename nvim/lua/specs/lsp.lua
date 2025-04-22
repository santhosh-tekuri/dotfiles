-- lsp setup

local spec = {
    "williamboman/mason.nvim",
}

function spec.config()
    require("mason").setup()
    for _, f in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
        local name = vim.fn.fnamemodify(f, ':t:r')
        local cmd = dofile(f).cmd[1]
        if vim.fn.executable(cmd) == 0 then
            vim.cmd("MasonInstall " .. name)
        end
        vim.lsp.enable(name)
    end
end

return spec
