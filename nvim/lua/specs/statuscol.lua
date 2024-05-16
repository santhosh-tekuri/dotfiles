-- configurable statuscolumn and click handlers

local spec = { "luukvbaal/statuscol.nvim" }

function spec.config()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup {
        setopt = true,
        relculright = true,
        segments = {
            { text = { "%C" },             click = "v:lua.ScFa" }, -- fold
            {
                sign = {
                    namespace = { "diagnostic" },
                    maxwidth = 1,
                    colwidth = 2,
                    auto = false,
                    fillchar = " ",
                    fillcharhl = "StatusColumnSeparator",
                },
                click = "v:lua.ScSa",
            },
            { text = { builtin.lnumfunc }, click = "v:lua.ScLa" }, -- linenum
            { text = { " " } },
            {
                sign = {
                    namespace = { "gitsign" },
                    maxwidth = 1,
                    colwidth = 2,
                    auto = false,
                    fillchar = " ",
                    fillcharhl = "StatusColumnSeparator",
                },
                click = "v:lua.ScSa",
            },
        },
    }
end

return spec
