-- file explorer: edit your filesystem like a buffer

local spec = { "stevearc/oil.nvim" }

function spec.config()
    require("oil").setup {
        float = {
            max_width = 70,
            max_height = 20,
            win_options = {
                winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator",
            }
        }
    }
    vim.keymap.set("n", "<leader>e", "<CMD>Oil --float<CR>", { desc = "Explore parent directory" })
end

return spec

--[[
<leader>e       open file explorer
--]]
