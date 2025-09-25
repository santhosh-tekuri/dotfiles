local M = {}

local function bufname(bufnr)
    local name = vim.fn.bufname(bufnr)
    if name == "" then
        name = string.format("%q", vim.bo[bufnr].buftype)
    end
    return name
end

local function openfunc(how)
    return function(item)
        if type(item) == "string" then
            item = vim.fn.bufadd(item)
            vim.bo[item].buflisted = true
        end
        if how == "tab" then
            vim.cmd("tabnew | buffer " .. item)
        elseif how == "edit" then
            local w = vim.fn.win_findbuf(item)[1]
            if w then
                if w ~= vim.api.nvim_get_current_win() then
                    vim.api.nvim_set_current_win(w)
                    return
                end
            end
            vim.cmd("buffer " .. item)
        elseif how == "split" then
            vim.cmd("sbuffer " .. item)
        elseif how == "vsplit" then
            vim.cmd("vertical sbuffer " .. item)
        end
    end
end

local function tolines(iter, opts)
    local func = function(item) return item end
    if opts["key"] then
        func = function(item)
            return item[opts["key"]] or ""
        end
    elseif opts["text_cb"] then
        func = opts["text_cb"]
    end
    local function replacenl(line)
        local str, _ = string.gsub(line, "\n", " ")
        return str
    end
    return iter:map(func):map(replacenl):totable()
end

local function matchfunc(query)
    local funcs = {}
    for word in query:gmatch("%S+") do
        local inverse = word:sub(1, 1) == "!"
        if inverse then
            word = word:sub(2)
        end
        local func
        if word:sub(1, 1) == "^" then
            local str = word:sub(2)
            if #str > 0 then
                func = function(txt)
                    local i, j = txt:find(str, 1, true)
                    return i == 1 and { i, j } or nil
                end
            end
        elseif word:sub(-1) == "$" then
            local str = word:sub(1, -2)
            if #str > 0 then
                func = function(txt)
                    return txt:sub(- #str) == str and { #txt - #str + 1, #txt } or nil
                end
            end
        elseif #word > 0 then
            local str = word
            func = function(txt)
                local i, j = txt:find(str, 1, true)
                return i and { i, j } or nil
            end
        end
        if func then
            if inverse then
                local f = func
                func = function(txt)
                    local p = f(txt)
                    return not p and {} or nil
                end
            end
            table.insert(funcs, { func, not string.find(word, "%u") })
        end
    end
    if #funcs == 0 then
        return nil
    end
    return function(txt)
        local txtlower, pos = nil, {}
        for _, f in ipairs(funcs) do
            local t = txt
            if f[2] then
                if not txtlower then
                    txtlower = txt:lower()
                end
                t = txtlower
            end
            local p = f[1](t)
            if not p then
                return nil
            end
            if #p > 0 then
                table.insert(pos, p)
            end
        end
        return pos
    end
end

local function match(items, query, opts, on_list)
    local func = matchfunc(query)
    if not func then
        return nil
    end
    local text_cb = opts.text_cb
    if not text_cb and opts.key then
        local key = opts.key
        text_cb = function(item)
            return item[key]
        end
    end

    local from, cancel = 1, false
    local function run()
        local start = vim.uv.hrtime()
        local mitems, pos = {}, {}
        while from <= #items do
            local item = items[from]
            local txt = text_cb and text_cb(item) or item
            local p = func(txt)
            if p then
                table.insert(mitems, item)
                table.insert(pos, p)
            end
            from = from + 1
            if from % 100 == 0 and (vim.uv.hrtime() - start > 1e6) then
                if not cancel then
                    if #mitems > 0 then
                        on_list({ mitems, pos }, { partial = true })
                    end
                    vim.defer_fn(run, 1)
                end
                return
            end
        end
        on_list({ mitems, pos }, { partial = true, done = true })
    end
    run()
    return function()
        cancel = true
    end
end

function M.pick(prompt, src, onclose, opts)
    local lspbuf = vim.api.nvim_get_current_buf()
    opts = vim.tbl_deep_extend("force", { matchseq = 1 }, opts or {})

    local ritems, items, sitems = {}, {}, {}
    local function setitems(arr, ropts)
        if ropts and ropts.partial then
            vim.list_extend(ritems, arr)
        else
            ritems = arr
        end
        if opts.filter and opts.filter.func and opts.filter.enabled then
            if ropts and ropts.partial then
                vim.iter(ritems):filter(opts.filter.func):each(function(item)
                    table.insert(items, item)
                end)
            else
                items = vim.tbl_filter(opts.filter.func, ritems)
            end
        else
            items = ritems
        end
    end

    if not opts["live"] then
        if type(src) == "function" then
            local srcopts = {}
            if opts.filter and not opts.filter.func then
                srcopts.filter = opts.filter.enabled
            end
            src(function(result)
                opts["src"] = src
                M.pick(prompt, result, onclose, opts)
            end, srcopts)
            return
        end
        setitems(src)
        if #items == 0 then
            local name = prompt:sub(-1) == ':' and prompt:sub(1, -2) or prompt
            vim.api.nvim_echo({ { "No " .. name .. " to select", "WarningMsg" } }, false, {})
            onclose(nil, {})
            return
        elseif #items == 1 then
            onclose(items[1], { open = openfunc("edit") })
            return
        end
    end
    local ignore_query_change = false
    local qbuf = vim.api.nvim_create_buf(false, true)
    vim.b[qbuf].completion = false
    local qwin = vim.api.nvim_open_win(qbuf, true, {
        relative = "editor",
        width = vim.o.columns,
        height = 1,
        row = vim.o.lines,
        col = 0,
        style = "minimal",
        zindex = 250,
    })
    vim.api.nvim_set_option_value("statuscolumn", prompt .. " ", { scope = "local", win = qwin })
    vim.api.nvim_set_option_value("winhighlight", "NormalFloat:MsgArea", { scope = "local", win = qwin })

    vim.cmd.startinsert()

    local sbuf = vim.api.nvim_create_buf(false, true)
    local sconfig = {
        relative = "editor",
        style = "minimal",
        border = { '', '', '', ' ', '', '', '', ' ' },
        focusable = false,
        zindex = 100,
    }
    local swin = -1
    local sskip = 0
    local shmax, swmin = 10, 50
    local closed = nil
    local timer = nil

    local pwin = nil
    local pconfig = {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines - 1,
        focusable = false,
        zindex = 50,
    }
    local runtick, runcancel = 0, nil
    local ns = vim.api.nvim_create_namespace("fuzzyhl")
    local function update_status()
        local vtxt = {}
        if pwin then
            local pbuf = vim.api.nvim_win_get_buf(pwin)
            bufname(pbuf)
            table.insert(vtxt, { bufname(pbuf) .. "    ", "Special" })
        end
        if items and #items > #sitems then
            if runcancel then
                table.insert(vtxt, { "" .. #sitems, "Normal" })
                table.insert(vtxt, { "/" .. #items, "Comment" })
            else
                local txt = string.format("%d/%d", #sitems, #items)
                table.insert(vtxt, { txt, "Comment" })
            end
        else
            table.insert(vtxt, { "" .. #sitems, runcancel and "Normal" or "Comment" })
        end
        vim.api.nvim_buf_clear_namespace(qbuf, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(qbuf, ns, 0, 0, {
            virt_text = vtxt,
            virt_text_pos = "right_align",
            strict = false,
        })
    end
    local function cancelrun()
        runtick = runtick + 1
        if runcancel then
            runcancel()
            runcancel = nil
            update_status()
        end
    end
    local function show_preview()
        if not opts.preview then
            return
        end
        if pwin then
            vim.api.nvim_buf_clear_namespace(vim.api.nvim_win_get_buf(pwin), ns, 0, -1)
            vim.api.nvim_win_hide(pwin)
            pwin = nil
        end
        if not sitems or #sitems == 0 then
            return
        end
        local line = vim.fn.line('.', swin) + sskip
        local item = sitems[line]
        item = opts.preview(item)
        if not item then
            update_status()
            return
        end
        pwin = vim.api.nvim_open_win(item.bufnr, false, pconfig)
        vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:Normal", { scope = "local", win = pwin })
        vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = pwin })
        vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = pwin })
        if item.lnum and item.lnum > 0 then
            vim.api.nvim_win_call(pwin, function()
                vim.api.nvim_win_set_cursor(pwin, { item.lnum, item.col or 0 })
                if item.col then
                    local pbuf = vim.api.nvim_win_get_buf(pwin)
                    vim.api.nvim_buf_set_extmark(pbuf, ns, item.lnum - 1, item.col - 1, {
                        end_col = item.end_col - 1,
                        hl_group = "Incsearch",
                        strict = false,
                        priority = 900,
                    })
                end
                vim.cmd("normal! zz")
            end)
        end
        update_status()
    end

    local function close(copts)
        if closed then
            return
        end
        closed = true
        if timer then
            vim.fn.timer_stop(timer)
        end
        cancelrun()
        if pwin then
            vim.api.nvim_set_option_value("winhighlight", nil, { scope = "local", win = pwin })
            vim.api.nvim_set_option_value("cursorline", nil, { scope = "local", win = pwin })
            vim.api.nvim_buf_clear_namespace(vim.api.nvim_win_get_buf(pwin), ns, 0, -1)
            vim.api.nvim_win_close(pwin, true)
        end
        local line = vim.fn.line('.', swin) + sskip
        vim.cmd.stopinsert()
        vim.api.nvim_buf_delete(qbuf, {})
        vim.api.nvim_buf_delete(sbuf, {})
        if copts and copts["qflist"] then
            onclose(sitems, copts)
        else
            local item = nil
            if copts then
                if sitems ~= nil and line > 0 and line <= #sitems then
                    item = sitems[line]
                end
            end
            onclose(item, copts)
        end
    end

    local matchpos = nil
    local function renderitems()
        local iter = vim.iter(sitems):skip(sskip):take(shmax)
        local lines = tolines(iter, opts)
        vim.api.nvim_buf_clear_namespace(sbuf, ns, 0, -1)
        vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
        local ht = math.min(shmax, #lines)
        local w = vim.o.columns - 2
        if not opts.fill_width then
            w = swmin
            for _, line in ipairs(lines) do
                w = math.max(w, #line)
            end
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
        vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = swin })
        vim.api.nvim_set_option_value("scrolloff", 0, { scope = "local", win = swin })
        if opts["add_highlights"] then
            for i, line in ipairs(lines) do
                opts["add_highlights"](sitems[sskip + i], line, function(col, ext_opts)
                    ext_opts.priority = 800
                    vim.api.nvim_buf_set_extmark(sbuf, ns, i - 1, col, ext_opts)
                end)
            end
        end
        if matchpos ~= nil then
            local miter = vim.iter(matchpos):skip(sskip):take(shmax)
            for line, arr in miter:enumerate() do
                for _, p in ipairs(arr) do
                    if #p == 2 then
                        vim.api.nvim_buf_set_extmark(sbuf, ns, line - sskip - 1, p[1] - 1, {
                            end_col = p[2],
                            hl_group = "Special",
                            strict = false,
                            priority = 900,
                        })
                    end
                end
            end
        end
    end

    local function move(i)
        local line = vim.api.nvim_win_get_cursor(swin)[1] + i
        if line > 0 and line <= vim.api.nvim_buf_line_count(sbuf) then
            vim.api.nvim_win_set_cursor(swin, { line, 0 })
            show_preview()
            return
        end
        local t = sskip
        if line == 0 then
            if sskip == 0 then -- last item
                sskip = math.max(#sitems - 10, 0)
                line = #sitems - sskip
            else -- item above viewport
                sskip = sskip - 1
                line = nil
            end
        elseif line + sskip < #sitems then -- item below viewport
            sskip = sskip + 1
            line = nil
        else -- first items
            sskip = 0
            line = #sitems > 0 and 1 or nil
        end
        if sskip ~= t then
            renderitems()
        end
        if line then
            vim.api.nvim_win_set_cursor(swin, { line, 0 })
        end
        if sskip ~= t or line then
            show_preview()
        end
    end
    local function keymap(lhs, func, args)
        vim.keymap.set("i", lhs, function()
            func(unpack(args or {}))
        end, { buffer = qbuf, nowait = true })
    end
    vim.api.nvim_create_autocmd('WinLeave', {
        buffer = qbuf,
        callback = function()
            close(nil)
        end
    })
    keymap("<tab>", function() end, {})
    if opts and opts["qflist"] then
        keymap("<c-q>", close, { { qflist = true } })
    end
    keymap("<cr>", close, { { open = openfunc("edit") } })
    keymap("<c-s>", close, { { open = openfunc("split") } })
    keymap("<c-v>", close, { { open = openfunc("vsplit") } })
    keymap("<c-t>", close, { { open = openfunc("tab") } })
    keymap("<esc>", close, { nil })
    keymap("<c-n>", move, { 1 })
    keymap("<c-p>", move, { -1 })
    keymap("<down>", move, { 1 })
    keymap("<up>", move, { -1 })
    keymap("<c-c>", cancelrun, {})

    local function showitems(lines, pos, skip_sbuf)
        if closed then
            return
        end
        matchpos = pos
        sitems = lines

        -- show counts
        update_status()
        if skip_sbuf then
            return
        end

        sskip = 0
        if #lines == 0 then
            if swin ~= -1 then
                vim.api.nvim_win_hide(swin)
                swin = -1
            end
        else
            renderitems()
        end
        show_preview()
    end

    keymap("<c-g>", function()
        if opts.live then
            cancelrun()
            opts.live, opts.liveoff = nil, vim.fn.getline(".")
            vim.api.nvim_buf_set_lines(qbuf, 0, -1, false, {})
            local stc = prompt .. " %#Normal#" .. opts.liveoff .. "%#Special# > "
            vim.api.nvim_set_option_value("statuscolumn", stc, { scope = "local", win = qwin })
        elseif opts.liveoff then
            ignore_query_change = true
            vim.api.nvim_buf_set_lines(qbuf, 0, -1, false, { opts.liveoff })
            vim.fn.cursor(1, #opts.liveoff + 1)
            opts.live, opts.liveoff = true, nil
            vim.api.nvim_set_option_value("statuscolumn", prompt .. " ", { scope = "local", win = qwin })
            showitems(items, nil)
        end
    end)

    local function runmatch()
        local query = vim.fn.getline(1)
        cancelrun()
        local tick = runtick
        runcancel = function() end
        showitems({}, {})
        local count = 0
        runcancel = match(items, query, opts, function(result, ropts)
            if tick == runtick then
                count = count + 1
                ropts = ropts or {}
                if ropts.done or not ropts.partial then
                    -- vim.print("count: " .. count)
                    runcancel = nil
                end
                local skip_sbuf = ropts.partial and sskip + shmax <= #sitems
                vim.list_extend(sitems, result[1])
                vim.list_extend(assert(matchpos), result[2])
                showitems(sitems, matchpos, skip_sbuf)
                if ropts.partial then
                    vim.cmd.redraw()
                end
            end
        end)
    end

    if opts and opts.filter then
        keymap("<c-h>", function()
            opts.filter.enabled = not opts.filter.enabled
            local function refresh(result)
                setitems(result)
                local query = vim.fn.getline(1)
                if #query == 0 or opts.live then
                    showitems(items)
                else
                    runmatch()
                end
            end
            if opts.filter.func then
                refresh(ritems)
            else
                opts.src(function(result)
                    refresh(result)
                end, { filter = opts.filter.enabled })
            end
        end)
    end
    showitems(items or {})
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = qbuf,
        callback = function()
            if ignore_query_change then
                ignore_query_change = false
                return
            end
            if timer then
                vim.fn.timer_stop(timer)
                timer = nil
            end
            local query = vim.fn.getline(1)
            if #query > 0 then
                cancelrun()
                if opts.live then
                    timer = vim.fn.timer_start(250, function()
                        local tick = runtick
                        setitems({})
                        showitems(items, nil)
                        vim.api.nvim_buf_call(lspbuf, function()
                            runcancel = src(function(result, ropts)
                                if tick == runtick then
                                    ropts = ropts or {}
                                    if ropts.done or not ropts.partial then
                                        runcancel = nil
                                    end
                                    local skip_sbuf = ropts.partial and sskip + shmax <= #sitems
                                    setitems(result, ropts)
                                    showitems(items, nil, skip_sbuf)
                                    if ropts.partial then
                                        vim.cmd.redraw()
                                    end
                                end
                            end, { query = query })
                        end)
                    end)
                else
                    timer = vim.fn.timer_start(150, runmatch)
                end
            else
                cancelrun()
                showitems(items or {}, nil)
            end
        end
    })
end

------------------------------------------------------------------------

local function read_lines(pipe, on_line, tick)
    local queue, qfirst, qlast = {}, 0, -1
    local line = nil
    local check = assert(vim.uv.new_check())
    local function processQ()
        while qlast - qfirst + 1 > 0 do
            local data = queue[qfirst]
            queue[qfirst] = nil
            qfirst = qfirst + 1
            local from = 1
            while from <= #data do
                local j = data:find("\n", from, true)
                local i = j
                if j then
                    if j > 1 and data[j - 1] == '\r' then
                        i = j - 1
                    end
                    if i ~= 1 then
                        if line then
                            line = line .. data:sub(from, i - 1)
                        else
                            line = data:sub(from, i - 1)
                        end
                    end
                    on_line(line)
                    line = nil
                    from = j + 1
                else
                    if line then
                        line = line .. data:sub(from)
                    else
                        line = data:sub(from)
                    end
                    break
                end
            end
        end
        _ = tick and tick()
    end
    check:start(processQ)
    pipe:read_start(function(err, data)
        assert(not err, err)
        if data then
            qlast = qlast + 1
            queue[qlast] = data
        else
            vim.uv.check_stop(check)
            processQ()
            if line then
                on_line(line)
            end
        end
    end)
end

local function cmd_items(path, args, line2item, on_list, partial)
    on_list = vim.schedule_wrap(on_list)
    local stdio = { nil, vim.uv.new_pipe(), vim.uv.new_pipe() }
    local items, errors = {}, {}
    local handle, _ = vim.uv.spawn(path, { args = args, stdio = stdio }, function(code)
        on_list(code == 0 and items or {}, { partial = partial, done = true })
    end)
    local tick_size = 10
    local tick = partial and function()
        if #items > tick_size then
            tick_size = 10000
            local t = items
            items = {}
            on_list(t, { partial = true })
        end
    end or nil
    read_lines(stdio[2], function(line)
        table.insert(items, line2item and line2item(line) or line)
    end, tick)
    read_lines(stdio[3], function(line)
        table.insert(errors, line)
    end)
    return function()
        if handle:is_active() then
            pcall(handle.kill, handle, 15)
        end
    end
end

------------------------------------------------------------------------

function M.select(items, opts, on_choice)
    local prompt = opts and opts["prompt"] or ""
    local popts = {}
    if opts and opts["format_item"] ~= nil then
        popts["text_cb"] = opts["format_item"]
    end
    M.pick(prompt, items, on_choice, popts)
end

local function fileshorten(fname)
    if vim.fn.isabsolutepath(fname) == 0 then
        return fname
    end
    local name = vim.fn.fnamemodify(fname, ":.")
    if name == fname then
        name = vim.fn.fnamemodify(name, ":~")
    end
    return name
end

M.qfentry = {}

function M.qfentry.text(item)
    local file = item.filename or vim.fn.bufname(item.bufnr)
    local text = fileshorten(file)
    if item.lnum and item.lnum > 0 then
        text = text .. ":" .. item.lnum
    end
    if item.text then
        text = text .. " " .. item.text
    end
    return text
end

local typeHilights = {
    E = 'DiagnosticSignError',
    W = 'DiagnosticSignWarn',
    I = 'DiagnosticSignInfo',
    N = 'DiagnosticSignHint',
    H = 'DiagnosticSignHint',
}

function M.qfentry.add_highlights(item, line, add_highlight)
    local i = line:find(":", 1, true)
    if i then
        add_highlight(0, {
            end_col = i - 1,
            hl_group = "qfFilename",
            strict = false,
        })
        local k = line:find(" ", i + 1, true)
        assert(k ~= nil)
        add_highlight(i, {
            end_col = k - 1,
            hl_group = "qfLineNr",
            strict = false,
        })
        if item.type then
            add_highlight(k, {
                end_col = #line,
                hl_group = typeHilights[item.type],
                strict = false,
            })
        else
            local matches = item.matches
            if not matches then
                if item.lnum and item.col and item.end_col then
                    if item.lnum > 0 and item.col > 0 and item.end_col > 0 then
                        matches = { { item.col, item.end_col } }
                    end
                end
            end
            for _, m in ipairs(matches or {}) do
                add_highlight(k + m[1] - 1, {
                    end_col = k + m[2],
                    hl_group = "ErrorMsg",
                    strict = false,
                })
            end
        end
    end
end

function M.qfentry.filter_cwd(item)
    local file = item.filename
    file = vim.fn.fnamemodify(file, ":.")
    return vim.fn.isabsolutepath(file) == 0
end

function M.qfentry.preview(item)
    local bufnr = item.bufnr
    if not bufnr then
        bufnr = vim.fn.bufadd(item.filename)
    end
    return {
        bufnr = bufnr,
        lnum = item.lnum,
        col = item.col,
        end_col = item.end_col,
        matches = item.matches,
    }
end

function M.qfentry.open(item, opts)
    if item ~= nil then
        if opts["qflist"] then
            vim.fn.setqflist(item)
            vim.cmd.copen()
        else
            vim.cmd("normal! m'")
            opts["open"](item.bufnr or item.filename)
            vim.fn.cursor(item["lnum"], item["col"] + 1)
            vim.cmd("normal! zz")
        end
    end
end

------------------------------------------------------------------------

local function files(on_list, opts)
    local args = { "--type=f", "--type=l", "--color=never", "-E=.git" }
    if not opts.filter then
        table.insert(args, "--hidden")
    end
    cmd_items("fd", args, nil, on_list)
end

local function edit(item, opts)
    if item then
        if opts["qflist"] then
            vim.fn.setqflist(vim.tbl_map(function(file)
                return { filename = file, text = file }
            end, item))
            vim.cmd.copen()
        else
            opts["open"](item)
        end
    end
end

function M.pick_file()
    if vim.fn.executable("fd") == 0 then
        vim.api.nvim_echo({ { "fd is not available", "ErrorMsg" } }, false, {})
        return
    end
    M.pick("File:", files, edit, { qflist = true, filter = { enabled = true } })
end

------------------------------------------------------------------------

local function buffers()
    local cur = vim.fn.bufnr("%")
    local alt = vim.fn.bufnr("#")
    local items = {}
    for _, bufinfo in ipairs(vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })) do
        if bufinfo.bufnr == alt then
            table.insert(items, 1, bufinfo.bufnr)
        elseif bufinfo.bufnr ~= cur then
            table.insert(items, bufinfo.bufnr)
        end
    end
    return items
end

function M.pick_buffer()
    M.pick("Buffer:", buffers(), edit, { text_cb = bufname })
end

------------------------------------------------------------------------

local function grep_line2item(line)
    local i = line:find(":", 1, true)
    if i then
        local j = assert(line:find(":", i + 1, true))
        local from = j + 1
        local text, textlen = {}, 0
        local matches = {}
        while true do
            local x, y = line:find("[0m[31m", from, true)
            if not x then
                table.insert(text, line:sub(from))
                break
            end
            local m, n = line:find("[0m", y + 1, true)
            if not m then
                table.insert(text, line:sub(from))
                break
            end
            table.insert(text, line:sub(from, x - 1))
            textlen = textlen + x - 1 - from + 1
            local col = textlen + 1
            table.insert(text, line:sub(y + 1, m - 1))
            textlen = textlen + (m - 1 - (y + 1) + 1)
            table.insert(matches, { col, textlen })
            from = n + 1
        end
        local lnum = tonumber(line:sub(i + 5, j - 5))
        return {
            filename = line:sub(5, i - 1 - 4),
            lnum = lnum,
            col = #matches > 0 and matches[1][1] or nil,
            end_lnum = lnum,
            end_col = #matches > 0 and matches[1][2] + 1 or nil,
            matches = #matches > 0 and matches or nil,
            text = table.concat(text),
        }
    else
        return {
            filename = line:sub(5, -5),
        }
    end
end

local function grep(on_list, opts)
    local args = {
        "--line-number",
        "--no-heading", "--color=always",
        "--no-config", "--smart-case",
        "--max-columns=300",
        "--max-columns-preview",
        "--colors=path:none",
        "--colors=line:none",
        "--colors=match:fg:red",
        "--colors=match:style:nobold",
        "-g=!**/.git/**",
    }
    local query = opts.query
    while query:sub(1, 1) == '-' do
        local i, j = query:find("%s+")
        if not i then
            on_list({})
            return
        end
        table.insert(args, query:sub(1, i - 1))
        query = query:sub(j + 1)
        if args[#args] == "--" then
            break
        end
    end
    if query == "" then
        on_list({})
        return
    end
    if args[#args] ~= "--" then
        table.insert(args, "--")
    end
    table.insert(args, query)
    return cmd_items("rg", args, grep_line2item, on_list, true)
end

function M.pick_grep()
    if vim.fn.executable("rg") == 0 then
        vim.api.nvim_echo({ { "ripgrep is not available", "ErrorMsg" } }, false, {})
        return
    end
    M.pick("Grep:", grep, M.qfentry.open, {
        text_cb = M.qfentry.text,
        live = true,
        add_highlights = M.qfentry.add_highlights,
        preview = M.qfentry.preview,
        qflist = true,
        fill_width = true,
    })
end

------------------------------------------------------------------------

local function help()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = 'help'
    local tags = vim.api.nvim_buf_call(buf, function() return vim.fn.taglist('.*') end)
    vim.api.nvim_buf_delete(buf, { force = true })
    return tags
end

local function open_help(item)
    if item then
        vim.schedule(function()
            vim.cmd("help " .. item.name)
        end)
    end
end

function M.pick_help()
    M.pick("Help:", help(), open_help, { key = "name" })
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

local function pick_lsp_item(prompt, func, filter)
    M.pick(prompt, lsp_items(func), M.qfentry.open, {
        text_cb = M.qfentry.text,
        add_highlights = M.qfentry.add_highlights,
        preview = M.qfentry.preview,
        qflist = true,
        filter = filter,
        fill_width = true,
    })
end

function M.pick_declaration()
    pick_lsp_item("Declaration:", vim.lsp.buf.declaration)
end

function M.pick_definition()
    pick_lsp_item("Definition:", vim.lsp.buf.definition)
end

function M.pick_type_definition()
    pick_lsp_item("TypeDefinition:", vim.lsp.buf.type_definition)
end

function M.pick_implementation()
    pick_lsp_item("Implementation:", vim.lsp.buf.implementation)
end

function M.pick_reference()
    pick_lsp_item("Reference:", function(opts)
        return vim.lsp.buf.references(nil, opts)
    end, { func = M.qfentry.filter_cwd, enabled = true })
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

local function document_symbol_text(item)
    local text = item["text"]
    local index = string.find(text, ' ')
    if index then
        text = string.sub(text, index + 1)
    end
    return string.format("%-80s %13s", text, item["kind"])
end

local function document_symbol_add_highlights(item, line, add_highlight)
    add_highlight(#line - 13, {
        end_col = #line,
        hl_group = "Comment",
        strict = false,
    })
end

function M.pick_document_symbol()
    M.pick("DocSymbol:", document_symbols, M.qfentry.open, {
        text_cb = document_symbol_text,
        preview = M.qfentry.preview,
        add_highlights = document_symbol_add_highlights,
    })
end

local function workspace_symbols(on_list, opts)
    return vim.lsp.buf.workspace_symbol(opts.query, {
        on_list = function(result)
            on_list(vim.tbl_filter(filter_symbol, result.items))
        end
    })
end

local function workspace_symbol_text(item)
    local text = item["text"]
    local index = string.find(text, ' ')
    if index then
        text = string.sub(text, index + 1)
    end
    local line = string.format("%-13s %s", item.kind, text)
    local file = fileshorten(item.filename)
    local w = vim.o.columns - #line - #file - 3
    return string.format("%s %s%s", line, string.rep(" ", w), file)
end

local function workspace_symbol_add_highlights(item, line, add_highlight)
    add_highlight(0, {
        end_col = 13,
        hl_group = "Comment",
        strict = false,
    })
    local text = item.text
    local index = string.find(text, ' ')
    if index then
        text = string.sub(text, index + 1)
    end
    add_highlight(14 + #text, {
        end_col = vim.o.columns,
        hl_group = "qfFilename",
        strict = false,
    })
end

function M.pick_workspace_symbol()
    M.pick("WorkSymbol:", workspace_symbols, M.qfentry.open, {
        text_cb = workspace_symbol_text,
        preview = M.qfentry.preview,
        add_highlights = workspace_symbol_add_highlights,
        live = true,
        filter = { func = M.qfentry.filter_cwd, enabled = true },
    })
end

------------------------------------------------------------------------

local function diagnostics(bufnr)
    return function(on_list)
        on_list(vim.diagnostic.toqflist(vim.diagnostic.get(bufnr)))
    end
end

local function pick_diagnostic(bufnr)
    local prompt = bufnr and "DocDiagnostic" or "WorkDiagnostic"
    return M.pick(prompt, diagnostics(bufnr), M.qfentry.open, {
        text_cb = M.qfentry.text,
        preview = M.qfentry.preview,
        add_highlights = M.qfentry.add_highlights,
        qflist = true,
        filter = bufnr and nil or { func = M.qfentry.filter_cwd, enabled = true },
        fill_width = true,
    })
end

function M.pick_document_diagnostic()
    return pick_diagnostic(0)
end

function M.pick_workspace_diagnostic()
    return pick_diagnostic(nil)
end

------------------------------------------------------------------------

function M.setup()
    vim.ui.select = M.select
    vim.keymap.set('n', '<leader>f', M.pick_file)
    vim.keymap.set('n', '<leader>b', M.pick_buffer)
    vim.keymap.set('n', '<leader>h', M.pick_help)
    vim.keymap.set('n', '<leader>/', M.pick_grep)
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspPickers', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gD', M.pick_declaration, opts("Goto declaration"))
            vim.keymap.set('n', 'gd', M.pick_definition, opts("Goto definition"))
            vim.keymap.set('n', 'gi', M.pick_implementation, opts("Goto implementation"))
            vim.keymap.set('n', 'gy', M.pick_type_definition, opts("Goto type definition"))
            vim.keymap.set('n', '<leader>r', M.pick_reference, opts("Goto reference"))
            vim.keymap.set('n', '<leader>s', M.pick_document_symbol, opts("Open symbol picker"))
            vim.keymap.set('n', '<leader>S', M.pick_workspace_symbol, opts("Open workspace symbol picker"))
            vim.keymap.set('n', '<leader>d', M.pick_document_diagnostic, opts("Open diagnostic picker"))
            vim.keymap.set('n', '<leader>D', M.pick_workspace_diagnostic, opts("Open workspace diagnostic picker"))
        end,
    });
end

return M
