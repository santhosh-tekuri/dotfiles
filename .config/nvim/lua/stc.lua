--- statuscolumn: sign lnum git

---@diagnostic disable-next-line: duplicate-set-field
function _G.StatusColumn()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)

    local sign = nil
    local git = nil
    local lnum = { vim.v.lnum - 1, 0 }
    for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, lnum, lnum, { details = true, type = "sign" })) do
        if extmark[4].sign_text then
            local name = extmark[4].sign_hl_group or extmark[4].sign_name or ""
            if name:find("Git") then
                git = extmark[4]
            elseif sign == nil or extmark[4].priority > sign.priority then
                sign = extmark[4]
            end
        end
    end

    local comp = {}
    local function append(extmark)
        if extmark ~= nil then
            if extmark.sign_hl_group then
                table.insert(comp, "%#" .. extmark.sign_hl_group .. "#")
            end
            table.insert(comp, extmark.sign_text)
        else
            table.insert(comp, "  ")
        end
    end

    if vim.wo[win].signcolumn ~= "no" then
        append(sign)
    end
    if vim.v.virtnum == 0 then
        local nu = vim.wo[win].number
        local rnu = vim.wo[win].relativenumber
        local num
        if nu and rnu and vim.v.relnum == 0 then
            num = vim.v.lnum
        elseif rnu then
            num = vim.v.relnum
        else
            num = vim.v.lnum
        end
        table.insert(comp, "%=" .. num .. " ")
    end
    if vim.wo[win].signcolumn ~= "no" then
        append(git)
    end

    return table.concat(comp, "")
end

vim.o.statuscolumn = "%!v:lua.StatusColumn()"
