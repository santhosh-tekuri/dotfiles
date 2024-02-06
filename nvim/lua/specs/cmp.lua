local spec = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        -- snippet engine
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',

        -- sources
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
    },
}

local function deprio(kind)
    return function(e1, e2)
        if e1:get_kind() == kind then
            return false
        end
        if e2:get_kind() == kind then
            return true
        end
    end
end

local function no_detail_first(e1, e2)
    local types = require("cmp.types")
    if e1:get_kind() == e2:get_kind() then
        local item1 = e1:get_completion_item();
        local item2 = e2:get_completion_item();
        local detail1 = nil
        if item1.labelDetails and item1.labelDetails.detail then
            detail1 = item1.labelDetails.detail
        end
        local detail2 = nil
        if item2.labelDetails and item2.labelDetails.detail then
            detail2 = item2.labelDetails.detail
        end
        if detail1 == nil and detail2 ~= nil then
            return true
        end
        if detail1 ~= nil and detail2 == nil then
            return false
        end
    end
end

function spec.config()
    local cmp = require "cmp"
    local types = require("cmp.types")
    local luasnip = require "luasnip"
    luasnip.config.setup {}

    cmp.setup {
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
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
                elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
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
                no_detail_first,
                deprio(types.lsp.CompletionItemKind.Snippet),
                cmp.config.compare.offset,
                cmp.config.compare.exact,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.kind,
                cmp.config.compare.length,
                cmp.config.compare.order,
            }
        },
        formatting = {
            fields = { "abbr", "menu", "kind" },
            format = function(entry, vim_item)
                vim_item.menu = ""
                local item = entry:get_completion_item()
                if item.labelDetails and item.labelDetails.detail then
                    vim_item.menu = item.labelDetails.detail
                end
                return vim_item
            end,
        },
    }

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
