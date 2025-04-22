-- lsp setup

local spec = {
    "williamboman/mason.nvim",
}

local function ensure_installed(pkg_name)
    local registry = require("mason-registry")
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if not ok then
        vim.notify(("no mason package: %s"):format(pkg_name), vim.log.levels.ERROR)
        return
    end
    if pkg:is_installed() then
        return
    end
    pkg:install({ version = nil }):once(
        'closed',
        vim.schedule_wrap(function()
            if pkg:is_installed() then
                vim.notify(("[mason] %s was successfully installed"):format(pkg_name))
            else
                vim.notify(
                    ("[mason] %s install failed. see :Mason and :MasonLog"):format(pkg_name),
                    vim.log.levels.ERROR
                )
            end
        end)
    )
end

function spec.config()
    require("mason").setup()
    local servers = {}
    for _, f in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
        table.insert(servers, vim.fn.fnamemodify(f, ':t:r'))
    end
    for _, server in ipairs(servers) do
        ensure_installed(server)
    end
    vim.lsp.enable(servers)
end

return spec
