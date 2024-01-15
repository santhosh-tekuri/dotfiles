local spec = { "lewis6991/gitsigns.nvim" }

function spec.config()
    require("gitsigns").setup()
end

return spec
