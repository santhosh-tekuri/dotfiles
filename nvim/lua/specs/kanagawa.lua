return {
    "rebelot/kanagawa.nvim",
    opts={
        colors = {
            theme = {
                all = {
                    ui = {
                        bg_gutter = "none"
                    }
                }
            }
        },
        overrides = function(colors)
            local theme = colors.theme
            return {
                WinSeparator = { fg = theme.ui.nontext }, -- brighter
            }
        end,
    }
}
