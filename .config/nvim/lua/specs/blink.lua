-- completion plugin

local spec = { "saghen/blink.cmp", version = "*" }

function spec.config()
    require("blink.cmp").setup {
        keymap = {
            preset = "super-tab",
        },
        signature = {
            enabled = true,
        },
        completion = {
            list = {
                selection = {
                    auto_insert = false,
                },
            },
            menu = {
                draw = {
                    treesitter = { 'lsp' },
                    columns = {
                        { "label", "label_detail", gap = 1 },
                        { "kind" },
                    },
                    components = {
                        label = {
                            text = function(ctx) return ctx.label end,
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
                ['<enter>'] = { 'select_accept_and_enter', "fallback" },

            }
        }
    }
end

return spec
