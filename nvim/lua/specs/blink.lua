local spec = {
    "saghen/blink.cmp",
    version      = "*",
    dependencies = "rafamadriz/friendly-snippets",
}

function spec.config()
    require("blink.cmp").setup {
        keymap = {
            preset = "super-tab",
        },
        signature = {
            enabled = true,
        },
        completion = {
            menu = {
                scrollbar = false,
                draw = {
                    columns = {
                        { "label", "label_detail", gap = 1 },
                        { "kind" },
                    },
                    components = {
                        label = {
                            text = function(ctx) return ctx.label end,
                            highlight = 'BlinkCmpLabel',
                        },
                        label_detail = {
                            width = { max = 30 },
                            text = function(ctx) return ctx.label_detail end,
                            highlight = 'BlinkCmpLabelDescription',
                        },
                    },
                }
            },
            documentation = {
                auto_show = true,
            }
        }
    }
end

return spec
