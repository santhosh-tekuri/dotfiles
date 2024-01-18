return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "arkav/lualine-lsp-progress" },
    opts = {
        options = {
            icons_enabled = false,
            component_separators = { left = ' ', right = ' ' },
            section_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { {'lsp_progress', display_components = {'lsp_client_name', {'percentage'}}}},
            lualine_c = { 'filename' },
            lualine_x = { 'diagnostics' },
            lualine_y = { 'branch' },
            lualine_z = { 'location' }
        },
    }
}

