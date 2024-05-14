-- color highlighting for hex, rgb, hsl, CSS variables, and Tailwind CSS

local spec = { "norcalli/nvim-colorizer.lua" }

function spec.config()
    require("colorizer").setup()
end

return spec
