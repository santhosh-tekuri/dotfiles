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
                TroubleText = { fg = theme.ui.fg },
                TroubleTextInformation = { link = "DiagnosticInfo" },
                TroubleTextWarning = { link = "DiagnosticWarn" },
                TroubleTextHint = { link = "DiagnosticHint" },
                TroubleTextError = { link = "DiagnosticError" },
            }
        end,
    }
}
