local M = {}

local function tolines(items, opts)
    local func = nil
    if opts["key"] then
        func = function(item)
            return item[opts["key"]]
        end
    elseif opts["text_cb"] then
        func = opts["text_cb"]
    end
    if func then
        return vim.tbl_map(func, items)
    end
    return items
end

local function match_single(items, str, opts)
    if str:sub(1, 1) == "'" then
        str = str:sub(2)
        local ignorecase = not str:match("%u")
        if ignorecase then
            str = str:lower()
        end
        local func = nil
        if opts["key"] then
            func = function(item)
                return item[opts["key"]]
            end
        elseif opts["text_cb"] then
            func = opts["text_cb"]
        end
        local result = { {}, {} }
        for _, item in ipairs(items) do
            local text = func and func(item) or item
            if ignorecase then
                text = text:lower()
            end
            local from, to = text:find(str, 1, true)
            if from then
                table.insert(result[1], item)
                table.insert(result[2], { { from - 1, to - 1 } })
            end
        end
        return result
    end
    return vim.fn.matchfuzzypos(items, str, opts)
end

local function match(items, query, opts)
    local w = 0
    local pos = nil
    for word in query:gmatch("%S+") do
        if w == 1 then
            assert(pos ~= nil)
            local temp = {}
            for i, item in ipairs(items) do
                table.insert(temp, { item = item, pos = pos[i] })
            end
            items = temp
            local func
            if opts["key"] then
                local key = opts["key"]
                func = function(item)
                    return item["item"][key]
                end
            elseif opts["text_cb"] then
                local text_cb = opts["text_cb"]
                func = function(item)
                    return text_cb(item["item"])
                end
            else
                func = function(item)
                    return item["item"]
                end
            end
            opts = { text_cb = func, matchseq = 1 }
        elseif w > 1 then
            assert(pos ~= nil)
            for i, item in ipairs(items) do
                for _, p in ipairs(pos[i]) do
                    table.insert(item["pos"], p)
                end
            end
        end
        items, pos = unpack(match_single(items, word, opts))
        w = w + 1
    end
    if w > 1 then
        local temp = {}
        for i, item in ipairs(items) do
            table.insert(temp, item["item"])
            for _, p in ipairs(pos[i]) do
                table.insert(item["pos"], p)
            end
            pos[i] = item["pos"]
        end
        items = temp
    end
    return { items, pos }
end

function M.pick(prompt, src, onclose, opts)
    local lspbuf = vim.api.nvim_get_current_buf()
    opts = vim.tbl_deep_extend("force", { matchseq = 1 }, opts or {})
    local items = nil
    local sitems = nil
    if not opts["live"] then
        if type(src) == "function" then
            src(function(result)
                opts["src"] = src
                M.pick(prompt, result, onclose, opts)
            end)
            return
        end
        items = src
        if #items == 0 then
            vim.api.nvim_echo({ { "No " .. prompt .. " to select", "WarningMsg" } }, false, {})
            onclose(nil, {})
            return
        elseif #items == 1 then
            onclose(items[1], { open = vim.cmd.edit })
            return
        end
    end
    local cmdheight = vim.o.cmdheight
    vim.o.cmdheight = 0
    local pbuf = vim.api.nvim_create_buf(false, true)
    vim.b[pbuf].completion = false
    vim.api.nvim_open_win(pbuf, true, {
        relative = "editor",
        width = vim.o.columns,
        height = 1,
        row = vim.o.lines,
        col = 0,
        style = "minimal",
        border = { '', '', '', ' ', '', '', '', ':' },
    })
    vim.cmd("setlocal winhighlight=Normal:MsgArea,FloatBorder:Normal")

    -- show prompt
    local ns = vim.api.nvim_create_namespace("picker-prompt")
    vim.api.nvim_buf_set_extmark(pbuf, ns, 0, 0, {
        virt_text = { { prompt, "Comment" } },
        virt_text_pos = "right_align",
        strict = false,
    })
    vim.cmd.startinsert()

    local sbuf = vim.api.nvim_create_buf(false, true)
    local sconfig = {
        relative = "editor",
        style = "minimal",
        border = { '', '', '', '', '', '', '', ' ' },
        focusable = false,
    }
    local swin = -1
    local function close(copts)
        vim.o.cmdheight = cmdheight
        local item = nil
        if copts then
            local line = vim.fn.line('.', swin)
            if sitems ~= nil and line > 0 and line <= #sitems then
                item = sitems[line]
            end
        end
        vim.cmd.stopinsert()
        vim.api.nvim_buf_delete(pbuf, {})
        vim.api.nvim_buf_delete(sbuf, {})
        onclose(item, copts)
    end
    local function move(i)
        local line = vim.api.nvim_win_get_cursor(swin)[1] + i
        if line > 0 and line <= vim.api.nvim_buf_line_count(sbuf) then
            vim.api.nvim_win_set_cursor(swin, { line, 0 })
        end
    end
    local function keymap(lhs, func, args)
        vim.keymap.set("i", lhs, function()
            func(unpack(args))
        end, { buffer = pbuf })
    end
    keymap("<tab>", function() end, {})
    keymap("<cr>", close, { { open = vim.cmd.edit } })
    keymap("<c-s>", close, { { open = vim.cmd.split } })
    keymap("<c-v>", close, { { open = vim.cmd.vsplit } })
    keymap("<c-t>", close, { { open = vim.cmd.tabedit } })
    keymap("<esc>", close, { nil })
    keymap("<c-n>", move, { 1 })
    keymap("<c-p>", move, { -1 })
    keymap("<down>", move, { 1 })
    keymap("<up>", move, { -1 })
    ns = vim.api.nvim_create_namespace("fuzzyhl")
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
            local ht = math.min(10, #lines)
            local w = 15
            for _, line in ipairs(lines) do
                w = math.max(w, #line)
            end
            sconfig = vim.tbl_extend("force", sconfig, {
                width = w,
                height = ht,
                row = vim.o.lines - ht - 1,
                col = 0,
            })
            if swin == -1 then
                swin = vim.api.nvim_open_win(sbuf, false, sconfig)
            else
                vim.api.nvim_win_set_config(swin, sconfig)
            end
            vim.api.nvim_set_option_value("cursorline", true, { win = swin })
            if pos ~= nil then
                for line, arr in ipairs(pos) do
                    for _, p in ipairs(arr) do
                        local from, to
                        if type(p) == "table" then
                            from, to = p[1], p[2] + 1
                        else
                            from, to = p, p + 1
                        end
                        vim.api.nvim_buf_set_extmark(sbuf, ns, line - 1, from, {
                            end_col = to,
                            hl_group = "Special",
                            strict = false,
                        })
                    end
                end
            end
        end
    end
    setitems(items or {})
    local timer = nil
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = pbuf,
        callback = function()
            if timer then
                vim.fn.timer_stop(timer)
                timer = nil
            end
            local query = vim.fn.getline(1)
            if #query > 0 then
                if opts["live"] then
                    timer = vim.fn.timer_start(250, function()
                        vim.api.nvim_set_current_buf(lspbuf)
                        src(function(result)
                            setitems(result, nil)
                        end, query)
                        vim.api.nvim_set_current_buf(pbuf)
                    end)
                else
                    local matched = match(items, query, opts)
                    setitems(matched[1], matched[2])
                end
            else
                setitems(items or {}, nil)
            end
        end
    })
end

function M.select(items, opts, on_choice)
    local prompt = opts and opts["prompt"] or ""
    prompt = prompt:match("^%s*(.-)%s*$") or ""
    if #prompt > 1 and prompt:sub(-1) == ':' then
        prompt = prompt:sub(1, -2)
    end
    local popts = {}
    if opts and opts["format_item"] ~= nil then
        popts["text_cb"] = opts["format_item"]
    end
    M.pick(prompt, items, on_choice, popts)
end

local function fileshorten(absname)
    local fname = vim.fn.fnamemodify(absname, ":.")
    if fname == absname then
        fname = vim.fn.fnamemodify(fname, ":~")
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
        cmd = "find . -type f -not -path '*/.git/*'"
    end
    return vim.fn.systemlist(cmd)
end

local function edit(item, opts)
    if item then
        opts["open"](item)
    end
end

function M.pick_file()
    M.pick("File", files(), edit)
end

------------------------------------------------------------------------

local function buffers()
    local cur = vim.fn.bufnr("%")
    local alt = vim.fn.bufnr("#")
    local items = {}
    for _, bufinfo in ipairs(vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })) do
        local fname = fileshorten(bufinfo.name)
        if bufinfo.bufnr == alt then
            table.insert(items, 1, fname)
        elseif bufinfo.bufnr ~= cur then
            table.insert(items, fname)
        end
    end
    return items
end

function M.pick_buffer()
    M.pick("Buffer", buffers(), edit)
end

------------------------------------------------------------------------

local function lsp_items(func)
    return function(on_list)
        return func({
            on_list = function(result)
                on_list(result.items)
            end
        })
    end
end

local function lsp_item_text(item)
    local text = item["text"]:match("^%s*(.-)$") or ""
    return string.format("%s:%d:%d  %s", fileshorten(item["filename"]), item["lnum"], item["col"], text)
end

local function open_lsp_item(item, opts)
    if item ~= nil then
        opts["open"](item["filename"])
        vim.schedule(function()
            vim.fn.cursor(item["lnum"], item["col"])
        end)
    end
end

local function pick_lsp_item(prompt, func)
    M.pick(prompt, lsp_items(func), open_lsp_item, { text_cb = lsp_item_text })
end

function M.pick_definition()
    pick_lsp_item("Definition", vim.lsp.buf.definition)
end

function M.pick_type_definition()
    pick_lsp_item("TypeDefinition", vim.lsp.buf.type_definition)
end

function M.pick_implementation()
    pick_lsp_item("Implementation", vim.lsp.buf.implementation)
end

function M.pick_references()
    pick_lsp_item("Reference", function(opts)
        return vim.lsp.buf.references({}, opts)
    end)
end

------------------------------------------------------------------------

local exclude_symbols = {
    { "Constant", "Variable", "Object", "Number", "String", "Boolean", "Array" },
    lua = { "Package" },
}

local function filter_symbol(item)
    local kind = item["kind"]
    if vim.tbl_contains(exclude_symbols[1], kind) then
        return false
    end
    local tbl = exclude_symbols[vim.bo.filetype]
    if tbl ~= nil and vim.tbl_contains(tbl, kind) then
        return false
    end
    return true
end

local function document_symbols(on_list)
    return vim.lsp.buf.document_symbol({
        on_list = function(result)
            on_list(vim.tbl_filter(filter_symbol, result.items))
        end
    })
end

local function symbol_text(item)
    local text = item["text"]
    local index = string.find(text, ' ')
    if index then
        text = string.sub(text, index + 1)
    end
    return string.format("%-80s %11s", text, item["kind"])
end

function M.pick_document_symbol()
    M.pick("DocSymbol", document_symbols, open_lsp_item, { text_cb = symbol_text })
end

local function workspace_symbols(on_list, query)
    return vim.lsp.buf.workspace_symbol(query, {
        on_list = function(result)
            on_list(vim.tbl_filter(filter_symbol, result.items))
        end
    })
end

function M.pick_workspace_symbol()
    M.pick("WorkSymbol", workspace_symbols, open_lsp_item, { text_cb = symbol_text, live = true })
end

------------------------------------------------------------------------

function M.setup()
    vim.ui.select = M.select
    vim.keymap.set('n', '<leader>f', M.pick_file)
    vim.keymap.set('n', '<leader>b', M.pick_buffer)
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspPickers', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gd', M.pick_definition, opts("Goto definition"))
            vim.keymap.set('n', 'gi', M.pick_implementation, opts("Goto implementation"))
            vim.keymap.set('n', 'gy', M.pick_type_definition, opts("Goto type definition"))
            vim.keymap.set('n', '<leader>r', M.pick_references, opts("Goto reference"))
            vim.keymap.set('n', '<leader>s', M.pick_document_symbol, opts("Open symbol picker"))
            vim.keymap.set('n', '<leader>S', M.pick_workspace_symbol, opts("Open workspace symbol picker"))
        end,
    });
end

return M
