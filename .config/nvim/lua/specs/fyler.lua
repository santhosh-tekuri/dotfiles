local spec = { "A7Lavinraj/fyler.nvim" }

function spec.config()
    require("fyler").setup({
        default_explorer = true,
        close_on_select = false,
        icon_provider = function()
            return "", ""
        end,
        views = {
            explorer = {
                width = 0.3,
                kind = "split:rightmost",
            },
        },
    })
end

return spec
