return {
    "julian/vim-textobj-variable-segment",
    dependencies = {
        "kana/vim-textobj-user",
    }
}

--[[
substring in any identifier character followed by:
snake case: an underscore
camel case: a lowercase identifier character followed by an uppercase character

iv      variable segment
av      includes trailing underscore
--]]
