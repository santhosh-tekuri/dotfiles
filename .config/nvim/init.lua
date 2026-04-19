require("opts")
require("keymaps")
require("usercmds")
require("autocmds")
require("textobjs")
require("stc")

local plugins = {
    { src = "gh:santhosh-tekuri/silence.nvim" },
    { src = "gh:santhosh-tekuri/term.nvim" },
    { src = "gh:santhosh-tekuri/quickfix.nvim" },
    { src = "gh:santhosh-tekuri/picker.nvim" },
    { src = "gh:santhosh-tekuri/wordiff.nvim" },
    { src = "gh:santhosh-tekuri/git.nvim" },
    { src = "gh:smilhey/ed-cmd.nvim" },
    { src = "gh:stevearc/oil.nvim" },
    { src = "gh:lewis6991/gitsigns.nvim" },
    { src = "gh:nvim-treesitter/nvim-treesitter" },
    { src = "gh:windwp/nvim-ts-autotag" },
    { src = "gh:mason-org/mason.nvim" },
    { src = "gh:saghen/blink.cmp",               version = "1.*" },
    { src = "gh:kylechui/nvim-surround" },
    { src = "gh:norcalli/nvim-colorizer.lua" },
    { src = "gh:sontungexpt/url-open" },
    { src = "gh:nvim-lua/plenary.nvim" },
    { src = "gh:andythigpen/nvim-coverage" },
    { src = "gh:windwp/nvim-autopairs" },
    { src = "gh:tversteeg/registers.nvim" },
}

-- add plugins
vim.pack.add(vim.tbl_map(function(p)
    local src = p.src
    if src:sub(1, 3) == "gh:" then
        src = "https://github.com/" .. src:sub(4)
    end
    local version = nil
    if p.version then
        version = vim.version.range(p.version)
    else
        version = p.branch or p.tag or p.commit
    end
    return { src = src, version = version }
end, plugins))

-- configure plugins
for _, p in ipairs(vim.pack.get()) do
    vim.cmd.packadd(p.spec.name)
    local name = assert(p.spec.name)
    local dot = name:find(".", 1, true)
    if dot then
        name = name:sub(1, dot - 1)
    end
    if #vim.api.nvim_get_runtime_file("lua/specs/" .. name .. ".lua", true) == 1 then
        require("specs." .. name)
    end
end
