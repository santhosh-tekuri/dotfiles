local spec = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp" },

        -- use vsnip for snippets
        { "hrsh7th/cmp-vsnip" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/vim-vsnip" },
    },
}

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

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

            -- emulate intellij behavior
            ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                elseif vim.fn["vsnip#available"](1) == 1 then
                    feedkey("<Plug>(vsnip-expand-or-jump)", "")
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if vim.fn["vsnip#jumpable"](-1) == 1 then
                    feedkey("<Plug>(vsnip-jump-prev)", "")
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),
        sources = {
            { name = "nvim_lsp" },
        },
        matching = {
            disallow_fuzzy_matching = true,
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

    -- vim.cmd [[imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>']]
    -- vim.cmd [[smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>']]
    -- vim.cmd [[imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>']]
    -- vim.cmd [[smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>']]

    -- Use cmdline & path source for ':'
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

    -- Use buffer source for `/` and `?`
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })
end

return spec
