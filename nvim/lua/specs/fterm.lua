-- floating terminal

local spec = { "numToStr/FTerm.nvim" }

function spec.config()
    require("FTerm").setup {
        border     = "solid",
        hl         = 'StatusLine',
        dimensions = {
            height = 0.9,
            width = 0.9,
        },
    }
    vim.keymap.set('n', '<C-/>', '<CMD>lua require("FTerm").toggle()<CR>')
    vim.keymap.set('t', '<C-/>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
end

return spec

--[[
C-/         toggle terminal
--]]
