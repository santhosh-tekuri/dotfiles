local spec = {
  "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"
}

function spec.config()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "c", "lua", "vim", "vimdoc", "query", -- should always be installed
      "xml", "json", "yaml", "toml",        -- config related
      "go", "gomod", "gosum", "gowork",     -- golang related
      "rust",
    },
    highlight = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = false,
        node_incremental = "v",
        scope_incremental = false,
        node_decremental = "V",
      },
    },
  }
end

return spec
