local spec = { "lewis6991/gitsigns.nvim" }

function spec.config()
    require("gitsigns").setup({
        sign_priority = 100, -- priority for sign over diagnostic
    })
end

return spec
