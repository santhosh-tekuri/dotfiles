-- textobject for current line

return {
    "kana/vim-textobj-line",
    dependencies = {
        "kana/vim-textobj-user",
    }
}

--[[
al      current line
il      excludes leading, trailing whitespace
--]]
