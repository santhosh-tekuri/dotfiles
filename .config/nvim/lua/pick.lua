local function tolines(items, opts)
    local func = nil
    if opts["key"] ~= nil then
        local key = opts["key"]
        func = function(item)
            return item[key]
        end
    elseif opts["text_cb"] ~= nil then
        func = opts["text_cb"]
    end
    if func ~= nil then
        return vim.tbl_map(func, items)
    end
    return items
end

local function pick(prompt, src, onclose, opts)
    opts = vim.tbl_deep_extend("force", { matchseq = 1 }, opts or {})
    if type(src) == "function" then
        src(function(items)
            pick(prompt, items, onclose, opts)
        end)
        return
    end
    local items = src
    local sitems = nil
    if #items == 0 then
        vim.api.nvim_echo({ { "No " .. prompt .. " to select", "WarningMsg" } }, false, {})
        onclose(nil)
        return
    elseif #items == 1 then
        onclose(items[1])
        return
    end
    local pbuf = vim.api.nvim_create_buf(false, true)
    vim.b[pbuf].completion = false
    local width = math.min(70, vim.o.columns - 10)
    local height = 11
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    vim.api.nvim_open_win(pbuf, true, {
        relative = "editor",
        width = width,
        height = 1,
        row = row,
        col = col,
        style = "minimal",
        border = { '', '', '', '', '-', '-', '-', ' ' },
    })

    -- show prompt
    local ns = vim.api.nvim_create_namespace("picker-prompt")
    vim.api.nvim_buf_set_extmark(pbuf, ns, 0, 0, {
        virt_text = { { prompt .. " ", "Comment" } },
        virt_text_pos = "right_align",
        strict = false,
    })

    ns = vim.api.nvim_create_namespace("fuzzyhl")

    local sbuf = vim.api.nvim_create_buf(false, true)
    local function create_select_win()
        local swin = vim.api.nvim_open_win(sbuf, false, {
            relative = "editor",
            width = width,
            height = height - 2,
            row = row + 2,
            col = col,
            style = "minimal",
            border = { '', '', '', '', '', '', '', ' ' },
            focusable = false,
        })
        vim.api.nvim_set_option_value("cursorline", true, { win = swin })
        return swin
    end
    local swin = create_select_win()
    vim.cmd.startinsert()
    local function close(confirm)
        local item = nil
        if confirm then
            local line = vim.fn.line('.', swin)
            if sitems ~= nil and line > 0 and line <= #sitems then
                item = sitems[line]
            end
        end
        vim.cmd.stopinsert()
        vim.api.nvim_buf_delete(pbuf, {})
        vim.api.nvim_buf_delete(sbuf, {})
        onclose(item)
    end
    local function move(i)
        local line = vim.api.nvim_win_get_cursor(swin)[1]
        line = line + i
        if line > 0 and line <= vim.api.nvim_buf_line_count(sbuf) then
            vim.api.nvim_win_set_cursor(swin, { line, 0 })
        end
    end
    vim.keymap.set("i", "<cr>", function()
        close(true)
    end, { buffer = pbuf })
    vim.keymap.set("i", "<esc>", function()
        close(false)
    end, { buffer = pbuf })
    vim.keymap.set("i", "<c-n>", function()
        move(1)
    end, { buffer = pbuf })
    vim.keymap.set("i", "<c-p>", function()
        move(-1)
    end, { buffer = pbuf })
    vim.keymap.set("i", "<down>", function()
        move(1)
    end, { buffer = pbuf })
    vim.keymap.set("i", "<up>", function()
        move(-1)
    end, { buffer = pbuf })
    local function setitems(lines, pos)
        sitems = lines
        lines = tolines(lines, opts)
        vim.api.nvim_buf_clear_namespace(sbuf, ns, 0, -1)
        vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
        if #lines == 0 then
            if swin ~= -1 then
                vim.api.nvim_win_hide(swin)
                swin = -1
            end
        else
            if swin == -1 then
                swin = create_select_win()
            end
            vim.api.nvim_win_set_height(swin, math.min(height - 2, #lines))
            local w = width
            for _, line in ipairs(lines) do
                w = math.max(w, #line)
            end
            vim.api.nvim_win_set_width(swin, w)
            if pos ~= nil then
                for line, arr in ipairs(pos) do
                    for _, p in ipairs(arr) do
                        vim.api.nvim_buf_set_extmark(sbuf, ns, line - 1, p, {
                            end_col = p + 1,
                            hl_group = "Special",
                            strict = false,
                        })
                    end
                end
            end
        end
    end
    setitems(items)
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = pbuf,
        callback = function()
            local query = vim.fn.getline(1)
            if #query > 0 then
                local matched = vim.fn.matchfuzzypos(items, query, opts)
                setitems(matched[1], matched[2])
            else
                setitems(items, nil)
            end
        end
    })
end

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
    local prompt = opts and opts["prompt"] or ""
    local popts = {}
    if opts and opts["format_item"] ~= nil then
        popts["text_cb"] = opts["format_item"]
    end
    pick(prompt, items, on_choice, popts)
end

local function fileshorten(absname)
    local fname = vim.fn.fnamemodify(absname, ":.")
    if fname == absname then
        fname = vim.fn.fnamemodify(fname, ":~")
    end
    local width = 50
    fname = #fname > width and vim.fn.pathshorten(fname, 3) or fname
    if #fname > width then
        local dir = vim.fn.fnamemodify(fname, ":h")
        local file = vim.fn.fnamemodify(fname, ":t")
        if dir and file then
            file = file:sub(-(width - #dir - 2))
            fname = dir .. "/…" .. file
        end
    end
    return fname
end

------------------------------------------------------------------------

local function files()
    local cmd
    if vim.fn.executable("fd") == 1 then
        cmd = 'fd --type f --type l --color=never -E .git'
    elseif vim.fn.executable("rg") == 1 then
        cmd = 'rg --files --no-messages --color=never'
    else
        cmd = "find . -type f -not -path '*/git/*'"
    end
    return vim.fn.systemlist(cmd)
end

local function edit(item)
    if item then
        vim.cmd.edit(item)
    end
end

local function pick_file()
    pick("File", files(), edit)
end

vim.keymap.set('n', '<leader>f', pick_file)

------------------------------------------------------------------------

local function buffers()
    local cur = vim.fn.bufnr("%")
    local alt = vim.fn.bufnr("#")
    local items = {}
    for _, bufinfo in ipairs(vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })) do
        if bufinfo.bufnr == alt then
            table.insert(items, 1, vim.fn.fnamemodify(bufinfo.name, ":."))
        elseif bufinfo.bufnr ~= cur then
            table.insert(items, vim.fn.fnamemodify(bufinfo.name, ":."))
        end
    end
    return items
end

local function pick_buffer()
    pick("Buffer", buffers(), edit)
end

vim.keymap.set('n', '<leader>b', pick_buffer)

------------------------------------------------------------------------

local function definitions(on_list)
    return vim.lsp.buf.definition({
        on_list = function(result)
            on_list(result.items)
        end
    })
end

local function definition_text(item)
    return string.format("%s:%d:%d %s", fileshorten(item["filename"]), item["lnum"], item["col"], item["text"])
end

local function open_lsp_location(item)
    if item ~= nil then
        vim.cmd.edit(item["filename"])
        vim.schedule(function()
            vim.fn.cursor(item["lnum"], item["col"])
        end)
    end
end

local function pick_definition()
    pick("Definition", definitions, open_lsp_location, { text_cb = definition_text })
end

vim.keymap.set('n', '<leader>n', pick_definition)

------------------------------------------------------------------------

local exclude_symbols = {
    { "Constant", "Variable", "Object", "Number", "String", "Boolean", "Array" },
    lua = {
        "Package",
    }
}

local function document_symbols(on_list)
    return vim.lsp.buf.document_symbol({
        on_list = function(result)
            on_list(vim.tbl_filter(function(item)
                local kind = item["kind"]
                if vim.tbl_contains(exclude_symbols[1], kind) then
                    return false
                end
                local tbl = exclude_symbols[vim.bo.filetype]
                if tbl ~= nil and vim.tbl_contains(tbl, kind) then
                    return false
                end
                return true
            end, result.items))
        end
    })
end

local function symbol_text(item)
    local text = item["text"]
    local index = string.find(text, ' ')
    if index then
        text = string.sub(text, index)
    end
    return string.format("%-57s %11s", text, item["kind"])
end

local function pick_document_symbol()
    pick("DocSymbol", document_symbols, open_lsp_location, { text_cb = symbol_text })
end

vim.keymap.set('n', '<leader>m', pick_document_symbol)
