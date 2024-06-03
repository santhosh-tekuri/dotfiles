-- colorscheme

local spec = { "rebelot/kanagawa.nvim" }

function spec.config()
    require("kanagawa").setup {
        overrides = function(colors)
            local theme = colors.theme
            return {
                WinSeparator = { fg = theme.ui.nontext }, -- brighter
                TroubleText = { fg = theme.ui.fg },
                TroubleTextInformation = { link = "DiagnosticInfo" },
                TroubleTextWarning = { link = "DiagnosticWarn" },
                TroubleTextHint = { link = "DiagnosticHint" },
                TroubleTextError = { link = "DiagnosticError" },
                MsgArea = { link = 'StatusLine' },
                MsgSeparator = { bg = theme.ui.bg },
                GitSignsAdd = { fg = theme.vcs.added, bg = theme.ui.bg },
                GitSignsChange = { fg = theme.vcs.changed, bg = theme.ui.bg },
                GitSignsDelete = { fg = theme.vcs.removed, bg = theme.ui.bg },
            }
        end,
    }

    vim.cmd.colorscheme "kanagawa"
end

return spec
