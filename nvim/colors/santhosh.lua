vim.cmd("hi clear")
vim.o.termguicolors = true
vim.g.colors_name = "santhosh"
-- disable all semantic highlights by clearing all the groups
for _, group in ipairs(vim.fn.getcompletion("@lsp.", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
end

local black = "#0d0f18"
local white = "#a5b6cf"
local red = "#dd6777"
local dull = "#747d8c"
local green = "#659239"
local greenLight = "#90ceaa"

local groups = {
    Default = { fg = white },
    Normal = { bg = black, fg = white },
    String = { fg = green },
    -- Operator = { fg = "#e6b99d" },
    Operator = { fg = "#ae8e57" },
    Type = { link = "Default" },
    Comment = { fg = "#747d8c", italic = true },
    Visual = { bg = "#292a2c" },
    Constant = { link = "String" },
    Function = { link = "Default" },
    Identifier = { link = "Default" },
    DiagnosticError = { fg = red },
    NormalFloat = { bg = "#202830" },
    StatusLine = { bg = "#2c2e33" },
    WinSeparator = { fg = dull },
    Search = { bg = "#202830" },
    CurSearch = { bg = "#4c5063" },
    PMenu = { link = "NormalFloat" },
    PmenuSel = { bg = white, fg = black },
    CmpItemKind = { link = "Comment" },
    MatchParen = { bg = "#4c5063", fg = "#FFFFFF" },
    GitSignsAdd = { fg = green },
    GitSignsChange = { fg = "#946a37" },
    GitSignsDelete = { fg = red },
    FloatBorder = { fg = dull },
    -- TelescopeNormal = { link = "NormalFloat" },
    -- TelescopeBorder = { link = "FloatBorder" },
    ["@constructor"] = { link = "Default" },
    ["@lsp.type.namespace.go"] = { link = "String" },
    ["@variable"] = { link = "Default" },
    ["@keyword"] = { fg = "#6699cc" },
    -- ["@keyword"] = { fg = "#6388c4" },
    ["@type"] = { fg = "#7b9695" },
    ["@type.builtin"] = { link = "@keyword" },
    ["@variable.builtin"] = { link = "@keyword" },
    ["@function.builtin"] = { link = "@keyword" },
    ["@constant.builtin"] = { link = "@keyword" },
    ["@punctuation"] = { link = "Operator" },
}
for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
end
