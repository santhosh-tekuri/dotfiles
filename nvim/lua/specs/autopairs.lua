local spec = { "jiangmiao/auto-pairs" }

function spec.config()
    vim.g.AutoPairsCenterLine = 0
    vim.g.AutoPairsShortcutJump = "<C-N>"
    vim.g.AutoPairsFlyMode = 1
end

return spec
