-- floating statusline

local spec = { "b0o/incline.nvim" }

local function render(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
    local modified = vim.bo[props.buf].modified
    filename = filename .. (modified and '*' or ' ')

    -- group based on diagnostic
    local group = "Text"
    for _, name in ipairs({ "ERROR", "WARN", "INFO", "HINT" }) do
        local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[name] })
        if n > 0 then
            group = 'DiagnosticVirtualText' .. string.lower(name)
            break
        end
    end

    return { filename, group = group }
end

function spec.config()
    require("incline").setup {
        debounce_threshold = {
            falling = 10,
            rising = 10,
        },
        render = render
    }
end

return spec
