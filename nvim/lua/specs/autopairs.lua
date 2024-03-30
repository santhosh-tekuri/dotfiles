local spec = { "altermo/ultimate-autopair.nvim" }

function spec.config()
    require("ultimate-autopair").setup()
end

return spec
