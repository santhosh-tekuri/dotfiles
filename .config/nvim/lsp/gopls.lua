--- @type vim.lsp.Config
return {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    settings = {
        gopls = {
            usePlaceholders = true,
            staticcheck = true,
            codelenses = {
                test = true,
            },
        },
    },
}
