local spec = { "tversteeg/registers.nvim" }

function spec.config()
    require("registers").setup {
        show_register_types = false,
        window = {
            transparency = 0,
        },
    }
end

return spec
