local spec = { "tversteeg/registers.nvim" }

function spec.config()
    require("registers").setup {
        show = "0123456789abcdefghijklmnopqrstuvwxyz*+\"-/_=#%.:",
        show_empty = false,
        show_register_types = false,
        window = {
            transparency = 0,
        },
    }
end

return spec
