local spec = {
    "saghen/blink.cmp",
    version = "*",
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
                            width = { min = 10, max = 30 },
                            text = function(ctx) return ctx.label_detail end,
                            highlight = 'BlinkCmpLabelDescription',
                        },
                    },
                }
            },
            documentation = {
                auto_show = true,
            }
        },
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                },
            },
            keymap = {
                preset = 'super-tab',
                ['<C-p>'] = { 'select_prev', 'fallback' },
                ['<C-n>'] = { 'select_next', 'fallback' },

            }
        }
    }
end

return spec
