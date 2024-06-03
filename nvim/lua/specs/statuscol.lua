-- configurable statuscolumn and click handlers

local spec = { "luukvbaal/statuscol.nvim" }

function spec.config()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup {
        setopt = true,
        relculright = true,
        segments = {
            { -- fold
                text = { "%C" },
                condition = { false },
                click = "v:lua.ScFa"
            },
            {
                sign = {
                    namespace = { "coverage" },
                    maxwidth = 1,
                    colwidth = 2,
                    auto = true,
                    fillchar = " ",
                    fillcharhl = "StatusColumnSeparator",
                },
                click = "v:lua.ScSa",
            },
            -- {
            --     sign = {
            --         namespace = { "diagnostic" },
            --         maxwidth = 1,
            --         colwidth = 2,
            --         auto = false,
            --         fillchar = " ",
            --         fillcharhl = "StatusColumnSeparator",
            --     },
            --     click = "v:lua.ScSa",
            -- },
            { text = { " " } },
            { text = { builtin.lnumfunc }, click = "v:lua.ScLa" }, -- linenum
            { text = { " " } },
            {
                sign = {
                    namespace = { "gitsign" },
                    maxwidth = 1,
                    colwidth = 1,
                    auto = false,
                    fillchar = " ",
                    fillcharhl = "Normal",
                },
                click = "v:lua.ScSa",
            },
        },
    }
end

return spec
