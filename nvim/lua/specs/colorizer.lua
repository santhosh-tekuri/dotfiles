local spec = { "norcalli/nvim-colorizer.lua" }

function spec.config()
    require("colorizer").setup()
end

return spec
