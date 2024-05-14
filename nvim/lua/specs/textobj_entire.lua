-- textobject for entire buffer

return {
    "kana/vim-textobj-entire",
    dependencies = {
        "kana/vim-textobj-user",
    }
}

--[[
ae      entire content of current buffer
ie      excludes leading, trailing whitespcae
--]]
