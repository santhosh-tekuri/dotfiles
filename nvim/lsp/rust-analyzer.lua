--- @type vim.lsp.Config
return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', '.git' },
    settings = {
        ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { features = "all" },
        }
    }
}
