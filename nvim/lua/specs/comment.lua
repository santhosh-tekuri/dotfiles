local spec = {
    "numToStr/Comment.nvim",
    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring"
    }
}

function spec.config()
    require("Comment").setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
    }
end

return spec

--[[
gc{noun}    toggle line comment
gb{noun}    toggle block comment

gcc         toggle line comment to current line
gcb         toggle block comment to current line

gco         insert comment on line above
gcO         insert comment on line below
gcA         insert comment end of line
--]]
