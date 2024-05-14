-- textobject for closest inner () {} or []

return {
    "Julian/vim-textobj-brace",
    dependencies = {
        "kana/vim-textobj-user",
    }
}

--[[
textobject for closest inner (), {} or []

aj      innermost braces
ij      excludes braces
--]]
