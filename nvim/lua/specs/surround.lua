return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
}

--[[
ys{motion}{char}        surround by {char}
cs{char}{replacement}   replace surrouding {char} by {replacement}
ds{char}                delete surrounding {char}

use `s` for {char} to find surrounding char automatically

S{char}                 surround selection with {char} in visual mode
<c-g>s{char}            surrount cursor with {char} in insert mode

Aliases:
b   represents )
B   represents }
r   represents ]
q   represents single/double/back quotes
--]]
