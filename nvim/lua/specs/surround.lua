-- add/delete/change surrounding pairs

local spec = {
    "kylechui/nvim-surround",
    event = "VeryLazy",
}

function spec.config()
    require("nvim-surround").setup {
        keymaps = {
            normal = "sa",
            delete = "sd",
            change = "sr",
        },
    }
end

return spec

--[[
sa{motion}{char}        surround by {char}
sr{char}{replacement}   replace surrouding {char} by {replacement}
sd{char}                delete surrounding {char}

use `s` for {char} to find surrounding char automatically

S{char}                 surround selection with {char} in visual mode
<c-g>s{char}            surrount cursor with {char} in insert mode

Aliases:
b   represents
B   represents }
r   represents ]
q   represents single/double/back quotes
--]]
