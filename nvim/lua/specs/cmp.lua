local spec = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp" },

        -- use vsnip for snippets
        { "hrsh7th/cmp-vsnip" },
        { "hrsh7th/vim-vsnip" },
    },
}

function spec.config()
    local cmp = require "cmp"

    cmp.setup {
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
            { name = "nvim_lsp" },
        },
        sorting = {
            comparators = {
                cmp.config.compare.order,
                cmp.config.compare.score,
                cmp.config.compare.exact,
                cmp.config.compare.sort_text,
                cmp.config.compare.offset,
                cmp.config.compare.kind,
                cmp.config.compare.length,
            }
        },
        formatting = {
            fields = { "abbr", "kind" },
            format = function(entry, vim_item)
                vim_item.menu = "" -- need to empty explictly to reduce popup width
                return vim_item
            end,
        },
    }
end

return spec
