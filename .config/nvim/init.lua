require("opts")
require("keymaps")
require("usercmds")
require("autocmds")
require("textobjs")
require("stc")

vim.pack.add({
    "https://github.com/santhosh-tekuri/silence.nvim",
    "https://github.com/santhosh-tekuri/term.nvim",
    "https://github.com/santhosh-tekuri/quickfix.nvim",
    "https://github.com/santhosh-tekuri/picker.nvim",
    "https://github.com/santhosh-tekuri/wordiff.nvim",
    "https://github.com/santhosh-tekuri/git.nvim",
    "https://github.com/smilhey/ed-cmd.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/windwp/nvim-ts-autotag",
    "https://github.com/mason-org/mason.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/norcalli/nvim-colorizer.lua",
    "https://github.com/sontungexpt/url-open",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/andythigpen/nvim-coverage",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/tversteeg/registers.nvim",
}, {
    load = function(plugin)
        vim.cmd.packadd(plugin.spec.name)
        local name = assert(plugin.spec.name)
        local dot = name:find(".", 1, true)
        if dot then
            name = name:sub(1, dot - 1)
        end
        if #vim.api.nvim_get_runtime_file("lua/specs/" .. name .. ".lua", true) == 1 then
            require("specs." .. name)
        end
    end
})
