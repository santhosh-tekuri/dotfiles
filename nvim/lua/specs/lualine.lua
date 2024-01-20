return {
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            icons_enabled = false,
            component_separators = { left = ' ', right = ' ' },
            section_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_c = { 'filename' },
            lualine_x = { 'diagnostics' },
            lualine_y = { 'branch' },
            lualine_z = { 'location' }
        },
    }
}

