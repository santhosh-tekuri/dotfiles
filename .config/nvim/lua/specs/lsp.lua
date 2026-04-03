-- lsp setup

vim.pack.add { "https://github.com/mason-org/mason.nvim" }

require("mason").setup()
for _, f in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
    local name = vim.fn.fnamemodify(f, ':t:r')
    local cmd = dofile(f).cmd[1]
    if vim.fn.executable(cmd) == 0 then
        vim.cmd("MasonInstall " .. name)
    end
    vim.lsp.enable(name)
end

-- non lsp packages
local packages = {
    shellcheck = "shellcheck",
}
for cmd, pkg in pairs(packages) do
    if vim.fn.executable(cmd) == 0 then
        vim.cmd("MasonInstall " .. pkg)
    end
end
