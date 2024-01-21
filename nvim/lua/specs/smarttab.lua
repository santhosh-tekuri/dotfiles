local spec = { "boltlessengineer/smart-tab.nvim" }

function spec.config()
    vim.keymap.set({'n', 'i'}, "<tab>", require('smart-tab').smart_tab)
end

return spec
