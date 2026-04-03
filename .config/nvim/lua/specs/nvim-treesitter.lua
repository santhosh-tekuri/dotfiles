-- treesitter configurations and abstraction layers

-- build = ":TSUpdate",

local ts = require("nvim-treesitter")
ts.install {
    "c", "lua", "vim", "vimdoc", "query",           -- should always be installed
    "regex", "bash", "markdown", "markdown_inline", -- for lsp docs
    "xml", "json", "yaml", "toml",                  -- config related
    "go", "gomod", "gosum", "gowork",               -- golang related
    "rust",
    "python",
}

vim.api.nvim_create_autocmd("FileType", {
    desc = "enable treesitter",
    callback = function(event)
        local lang = vim.treesitter.language.get_lang(event.match) or event.match
        if not vim.list_contains(ts.get_available(), lang) then
            return
        end
        ts.install(lang)
        local timer = assert(vim.uv.new_timer())
        local i = 0
        timer:start(0, 1000, vim.schedule_wrap(function()
            i = i + 1
            if vim.list_contains(ts.get_installed(), lang) then
                timer:close()
                if vim.api.nvim_buf_is_valid(event.buf) then
                    vim.treesitter.start(event.buf)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldlevel = 99
                end
            elseif i > 60 then
                timer:close()
            end
        end))
    end
})
