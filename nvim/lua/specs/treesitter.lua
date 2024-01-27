local spec = {
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"
}

function spec.config()
    require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "c", "lua", "vim", "vimdoc", "query",           -- should always be installed
            "regex", "bash", "markdown", "markdown_inline", -- for lsp docs
            "xml", "json", "yaml", "toml",                  -- config related
            "go", "gomod", "gosum", "gowork",               -- golang related
            "rust",
            "python",
        },
        auto_install = true,
        highlight = {
            enable = true,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = false,
                node_incremental = "<tab>",
                scope_incremental = false,
                node_decremental = "<s-tab>",
            },
        },
    }
end

return spec
