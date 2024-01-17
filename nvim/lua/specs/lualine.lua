local spec = { 
    "nvim-lualine/lualine.nvim",
    dependencies = { "arkav/lualine-lsp-progress" },
}

function spec.config()
    require("lualine").setup {
        options = {
            icons_enabled = false,
            component_separators = { left = ' ', right = ' '},
            section_separators = { left = ' ', right = ' '},
        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {},
            lualine_c = {'filename', 'lsp_progress'},
            lualine_x = {'diagnostics'},
            lualine_y = {'branch'},
            lualine_z = {'location'}
        },
    }
end

return spec
