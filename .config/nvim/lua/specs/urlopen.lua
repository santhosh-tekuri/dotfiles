-- open url under cursor in default browser

local spec = { "sontungexpt/url-open" }

function spec.config()
    require("url-open").setup {
        highlight_url = {
            all_urls = {
                enabled = true,
                fg = "#549bf5",
                underline = false,
            },
            cursor_move = {
                enabled = false,
            },
        },
    }
    vim.keymap.set("n", "gx", "<CMD>URLOpenUnderCursor<CR>")
end

return spec

--[[
gx      open url at cursor
--]]
