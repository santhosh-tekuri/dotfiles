-- textobjects

return {
    {
        "kana/vim-textobj-line",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "kana/vim-textobj-entire",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "Julian/vim-textobj-brace",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "glts/vim-textobj-comment",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "fvictorio/vim-textobj-backticks",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "beloglazov/vim-textobj-quotes",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "adolenc/vim-textobj-toplevel",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    {
        "julian/vim-textobj-variable-segment",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
}


--[[
al      current line
il      excludes leading, trailing whitespace

ae      entire content of current buffer
ie      excludes leading, trailing whitespcae

aj      innermost braces
ij      excludes braces

ic      just comment content
ac      includes comment delimeters
aC      includes delimeters, leading, trailing whitespace

i`      text inside backticks
a`      includes backticks

aq      includes quotes
iq      excludes quotes

iT      toplevel block
aT      includes trailing blank lines

substring in any identifier character followed by:
snake case: an underscore
camel case: a lowercase identifier character followed by an uppercase character

iv      variable segment
av      includes trailing underscore
--]]
