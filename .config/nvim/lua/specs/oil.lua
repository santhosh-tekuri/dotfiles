-- file explorer: edit your filesystem like a buffer

local spec = { "stevearc/oil.nvim" }

function spec.config()
    require("oil").setup {
        float = {
            max_width = 70,
            max_height = 20,
        }
    }
    vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
end

return spec

--[[
-       open file explorer
--]]
