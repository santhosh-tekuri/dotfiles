local spec = { "altermo/ultimate-autopair.nvim" }

function spec.config()
    require("ultimate-autopair").setup({
        config_internal_pairs = {
            -- disable ' autopair for rust
            {
                "'",
                "'",
                multiline = false,
                surround = true,
                cond = function(fn)
                    if fn.get_ft() == 'rust' then
                        return false
                    end
                    return not fn.in_lisp() or fn.in_string()
                end,
            },
        },
    })
end

return spec
