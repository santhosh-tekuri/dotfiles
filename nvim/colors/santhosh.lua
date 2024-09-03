vim.cmd("hi clear")
vim.o.termguicolors = true
vim.g.colors_name = "santhosh"
-- disable all semantic highlights by clearing all the groups
for _, group in ipairs(vim.fn.getcompletion("@lsp.", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
end

local white = "#9ca1a8"
local groups = {
    Default = { fg = white },
    Normal = { bg = "#000000", fg = white },
    String = { fg = "#90b99f" },
    -- String = { fg = "#678a45" },
    -- Operator = { fg = "#e6b99d" },
    Operator = { fg = "#ae8e57" },
    Type = { link = "Default" },
    Comment = { fg = "#4c5063" },
    Visual = { bg = "#1e1e1e" },
    Constant = { link = "String" },
    Function = { link = "Default" },
    Identifier = { link = "Default" },
    DiagnosticError = { fg = "#ac4143" },
    NormalFloat = { bg = "#121213" },
    PMenu = { link = "NormalFloat" },
    PmenuSel = { bg = white, fg = "#000000" },
    CmpItemKind = { link = "Comment" },
    MatchParen = { bg = "#4c5063", fg = "#FFFFFF" },
    GitSignsAdd = { fg = "#345b39" },
    GitSignsChange = { fg = "#946a37" },
    GitSignsDelete = { fg = "#ac4143" },
    -- FloatBorder = { fg = "#000000" },
    -- TelescopeNormal = { link = "NormalFloat" },
    -- TelescopeBorder = { link = "FloatBorder" },
    ["@constructor"] = { link = "Default" },
    ["@lsp.type.namespace.go"] = { link = "String" },
    ["@variable"] = { link = "Default" },
    ["@keyword"] = { fg = "#808ebe" },
    -- ["@keyword"] = { fg = "#6388c4" },
    ["@type.builtin"] = { link = "@keyword" },
    ["@variable.builtin"] = { link = "@keyword" },
    ["@function.builtin"] = { link = "@keyword" },
    ["@constant.builtin"] = { link = "@keyword" },
    ["@punctuation"] = { link = "Operator" },
    ["@lsp.type.parameter"] = { fg = "#ae8e57" },
}
for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
end

-- vim.api.nvim_set_hl(0, "@lsp.typemod.type.defaultLibrary", { link = "@keyword" })
