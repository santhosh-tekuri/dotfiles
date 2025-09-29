local M = {}

vim.api.nvim_set_hl(0, "qfFileName", { link = "Directory", default = true })
vim.api.nvim_set_hl(0, "qfLineNr", { link = "LineNr", default = true })
vim.api.nvim_set_hl(0, "qfMatch", { link = "Removed", default = true })
vim.api.nvim_set_hl(0, "PickerMatch", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "PickerDim", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "PickerPreviewMatch", { link = "CurSearch", default = true })
vim.api.nvim_set_hl(0, "PickerUndoSave", { link = "Added", default = true })

local function bufname(bufnr)
    local name = vim.fn.bufname(bufnr)
    if name == "" then
        name = vim.bo[bufnr].buftype
        if name == "" then
            return "[No Name]"
        end
        return string.format("[%s]", name)
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
                    local from = #txt - #str + 1
                    if from > 0 then
                        local i, j = txt:find(str, from, true)
                        return i == from and { i, j } or nil
                    end
                    return nil
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

local function match(items, func, opts, on_list)
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

local shmax = 10
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

    vim.schedule(vim.cmd.startinsert)

    local sbuf = vim.api.nvim_create_buf(false, true)
    local sconfig = {
        relative = "editor",
        style = "minimal",
        border = { '', '', '', '', '', '', '', ' ' },
        focusable = false,
        zindex = 100,
        col = 0,
    }
    local swin = nil
    local sskip = 0
    local swmin = 50
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
    local ns = vim.api.nvim_create_namespace("pickermatch")
    local function update_status()
        local vtxt = {}
        if pwin then
            local pbuf = vim.api.nvim_win_get_buf(pwin)
            bufname(pbuf)
            table.insert(vtxt, { bufname(pbuf) .. "    ", "qfFileName" })
        end
        if items and #items > #sitems then
            if runcancel then
                table.insert(vtxt, { "" .. #sitems, "Normal" })
                table.insert(vtxt, { "/" .. #items, "PickerDim" })
            else
                local txt = string.format("%d/%d", #sitems, #items)
                table.insert(vtxt, { txt, "PickerDim" })
            end
        else
            table.insert(vtxt, { "" .. #sitems, runcancel and "Normal" or "PickerDim" })
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
        vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = pwin })
        vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = pwin })
        if item.lnum and item.lnum > 0 then
            vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = pwin })
            vim.api.nvim_win_call(pwin, function()
                vim.api.nvim_win_set_cursor(pwin, { item.lnum, item.col or 0 })
                if item.col then
                    local pbuf = vim.api.nvim_win_get_buf(pwin)
                    vim.api.nvim_buf_set_extmark(pbuf, ns, item.lnum - 1, item.col - 1, {
                        end_col = item.end_col - 1,
                        hl_group = "PickerPreviewMatch",
                        strict = false,
                        priority = 900,
                    })
                end
                vim.cmd("normal! zz")
            end)
        end
        update_status()
    end

    local errbuf = nil
    local function show_error(errors)
        if errbuf then
            vim.api.nvim_buf_delete(errbuf, { force = true })
        end
        errbuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(errbuf, 0, -1, false, errors)
        local config = vim.tbl_extend("force", sconfig, {
            width = vim.o.columns - 1,
            height = #errors,
            row = vim.o.lines - #errors - 1,
        })
        local win = vim.api.nvim_open_win(errbuf, false, config)
        vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Error,FloatBorder:Error",
            { scope = "local", win = win })
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
            vim.api.nvim_set_option_value("wrap", nil, { scope = "local", win = pwin })
            vim.api.nvim_set_option_value("relativenumber", nil, { scope = "local", win = pwin })
            vim.api.nvim_buf_clear_namespace(vim.api.nvim_win_get_buf(pwin), ns, 0, -1)
            vim.api.nvim_win_close(pwin, true)
        end
        local line = vim.fn.line('.', swin) + sskip
        vim.cmd.stopinsert()
        if errbuf then
            vim.api.nvim_buf_delete(errbuf, { force = true })
        end
        vim.api.nvim_buf_delete(qbuf, {})
        vim.api.nvim_buf_delete(sbuf, {})
        if copts and sitems and #sitems > 0 then
            onclose(copts["qflist"] and sitems or sitems[line], copts)
        else
            onclose(nil, nil)
        end
    end

    local matchpos = nil
    local scrollns = vim.api.nvim_create_namespace("pickerscroll")
    local function renderscroll()
        vim.api.nvim_buf_clear_namespace(sbuf, scrollns, 0, -1)
        local ht = sconfig.height
        if #sitems > ht then
            local theight = math.max(1, math.floor(ht * ht / #sitems))
            local tpos = math.floor(sskip * (ht - theight) / (#sitems - ht))
            for i = 0, ht - 1 do
                local ch = (i >= tpos and i < tpos + theight) and '█' or ' '
                vim.api.nvim_buf_set_extmark(sbuf, scrollns, i, 0, {
                    virt_text = { { ch, 'PickerDim' } },
                    virt_text_pos = "right_align",
                    strict = false,
                })
            end
        end
    end

    local function renderitems()
        if errbuf then
            vim.api.nvim_buf_delete(errbuf, { force = true })
            errbuf = nil
        end
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
        w = w + 1
        sconfig = vim.tbl_extend("force", sconfig, {
            width = w,
            height = ht,
            row = vim.o.lines - ht - 1,
        })
        if swin then
            vim.api.nvim_win_set_config(swin, sconfig)
        else
            swin = vim.api.nvim_open_win(sbuf, false, sconfig)
        end
        vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = swin })
        vim.api.nvim_set_option_value("scrolloff", 0, { scope = "local", win = swin })
        vim.api.nvim_set_option_value("winhighlight", "FloatBorder:NormalFloat", { scope = "local", win = swin })
        if opts.select then
            vim.api.nvim_win_set_cursor(swin, { opts.select, 0 })
            opts.select = nil
        end
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
                            hl_group = "PickerMatch",
                            strict = false,
                            priority = 900,
                        })
                    end
                end
            end
        end
        renderscroll()
    end

    local function showitems(lines, pos, skip_sbuf)
        if closed then
            return
        end
        matchpos = pos
        sitems = lines

        -- show counts
        update_status()
        if skip_sbuf then
            renderscroll()
            return
        end

        sskip = 0
        if #lines == 0 then
            if swin then
                vim.api.nvim_win_hide(swin)
                swin = nil
            end
        else
            renderitems()
        end
        show_preview()
    end

    local function runmatch()
        local query = vim.fn.getline(1)
        local func = matchfunc(query)
        if not func then
            return
        end
        cancelrun()
        local tick = runtick
        runcancel = function() end
        showitems({}, {})
        runcancel = match(items, func, opts, function(result, ropts)
            if tick == runtick then
                ropts = ropts or {}
                if ropts.done or not ropts.partial then
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

    local function runlive()
        local query = vim.fn.getline(1)
        if not query:find("%S") then
            return
        end
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
                    if runcancel == nil and #items == 0 and ropts.errors and #ropts.errors > 0 then
                        show_error(ropts.errors)
                    end
                    if ropts.partial then
                        vim.cmd.redraw()
                    end
                end
            end, { query = query })
        end)
    end

    local function move(i)
        if not swin then
            return
        end
        local line = vim.api.nvim_win_get_cursor(swin)[1] + i
        if line > 0 and line <= vim.api.nvim_buf_line_count(sbuf) then
            vim.api.nvim_win_set_cursor(swin, { line, 0 })
            show_preview()
            return
        end

        local t = sskip
        local h = math.min(shmax, #sitems)
        if line == 0 then
            if sskip == 0 then -- last item
                sskip = math.max(#sitems - 10, 0)
                line = #sitems - sskip
            else -- item above viewport
                sskip = sskip - 1
                line = nil
            end
        elseif line > h then
            if line + sskip <= #sitems then -- item below viewport
                sskip = sskip + 1
                line = nil
            else -- first items
                sskip = 0
                line = #sitems > 0 and 1 or nil
            end
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
    local function scroll_list(lines)
        if swin then
            sskip = sskip + lines
            if sskip < 0 then
                sskip = 0
            elseif sskip > #sitems - shmax then
                sskip = #sitems - shmax
            end
            renderitems()
            show_preview()
        end
    end
    local function scroll_preview(down)
        if pwin then
            vim.api.nvim_win_call(pwin, function()
                vim.cmd("normal! " .. (down and "" or ""))
            end)
        end
    end
    local function keymap(lhs, func, args)
        vim.keymap.set("i", lhs, function()
            func(unpack(args or {}))
        end, { buffer = qbuf, nowait = true })
    end
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
    keymap("<c-d>", scroll_list, { shmax / 2 })
    keymap("<c-u>", scroll_list, { -shmax / 2 })
    keymap("<c-k>", vim.cmd, { "normal! 0d$" })
    keymap("<c-f>", scroll_preview, { true })
    keymap("<c-b>", scroll_preview, { false })
    keymap("<down>", move, { 1 })
    keymap("<up>", move, { -1 })
    keymap("<c-c>", cancelrun, {})
    keymap('<a-w>', function()
        if pwin then
            vim.wo[pwin].wrap = not vim.wo[pwin].wrap
        end
    end)
    keymap("<c-g>", function()
        if opts.live then
            cancelrun()
            opts.live, opts.liveoff = nil, vim.fn.getline(".")
            vim.api.nvim_buf_set_lines(qbuf, 0, -1, false, {})
            local stc = prompt .. " %#Normal#" .. opts.liveoff .. "%#PickerMatch# > "
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
    if opts and opts.keymaps then
        for lhs, func in pairs(opts.keymaps) do
            keymap(lhs, function()
                local line = vim.fn.line('.', swin) + sskip
                if sitems and sitems[line] then
                    func(sitems[line])
                end
            end, {})
        end
    end
    showitems(items or {})
    vim.api.nvim_create_autocmd('WinLeave', {
        buffer = qbuf,
        callback = function()
            close(nil)
        end
    })
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = qbuf,
        callback = function()
            if ignore_query_change then
                ignore_query_change = false
                return
            end
            if errbuf then
                vim.api.nvim_buf_delete(errbuf, { force = true })
                errbuf = nil
            end
            cancelrun()
            if timer then
                vim.fn.timer_stop(timer)
                timer = nil
            end
            if not vim.fn.getline(1):find("%S") then
                showitems(items or {}, nil)
            elseif opts.live then
                timer = vim.fn.timer_start(250, runlive)
            else
                timer = vim.fn.timer_start(#sitems > 400000 and 150 or 0, runmatch)
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
                    if j > 1 and data:sub(j - 1, j - 1) == '\r' then
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
        on_list(code == 0 and items or {}, { partial = partial, done = true, errors = code ~= 0 and errors or nil })
    end)
    local tick_size = shmax
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
            hl_group = "qfFileName",
            strict = false,
        })
        local k = assert(line:find(" ", i + 1, true))
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
            local matches = nil
            if item.user_data and type(item.user_data) == 'table' then
                matches = item.user_data.matches
            end
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
                    hl_group = "qfMatch",
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
    local function preview(item) return { bufnr = item } end
    M.pick("Buffer:", buffers(), edit, { text_cb = bufname, preview = preview })
end

------------------------------------------------------------------------

local function grep_line2item(line)
    local i = line:find(":", 1, true)
    if i then
        local j = line:find(":", i + 1, true)
        if not j then
            -- partial output, rg might have been killed
            return {
                filename = line:sub(5, i - 1 - 4),
            }
        end
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
            user_data = { matches = #matches > 0 and matches or nil },
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
        "--with-filename",
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
    local paths = {}
    local query = opts.query
    while query:sub(1, 1) == '-' do
        local i, j = query:find("%s+")
        if not i then
            on_list({})
            return
        end
        local flag = query:sub(1, i - 1)
        if flag:sub(1, #"--path=") == "--path=" then
            local path = flag:sub(#"--path=" + 1)
            table.insert(paths, vim.fn.expandcmd(path))
        else
            table.insert(args, query:sub(1, i - 1))
        end
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
    vim.list_extend(args, paths)
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

local function pick_lsp_item(prompt, func, filter)
    local src = function(on_list)
        return func({
            on_list = function(result)
                on_list(result.items)
            end
        })
    end
    M.pick(prompt, src, M.qfentry.open, {
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

local function document_symbol_add_highlights(_item, line, add_highlight)
    add_highlight(#line - 13, {
        end_col = #line,
        hl_group = "PickerDim",
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

local function workspace_symbol_add_highlights(item, _line, add_highlight)
    add_highlight(0, {
        end_col = 13,
        hl_group = "PickerDim",
        strict = false,
    })
    local symblen = #item.text
    local sp = item.text:find(' ', 1, true)
    if sp then
        symblen = symblen - sp
    end
    add_highlight(14 + symblen, {
        end_col = vim.o.columns,
        hl_group = "qfFileName",
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

local function pick_diagnostic(bufnr)
    local prompt = bufnr and "DocDiagnostic" or "WorkDiagnostic"
    local src = function(on_list)
        on_list(vim.diagnostic.toqflist(vim.diagnostic.get(bufnr)))
    end
    return M.pick(prompt, src, M.qfentry.open, {
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

local function undotree()
    local tree = vim.fn.undotree()
    local list, maxdepth, maxseq, curidx = {}, 0, 0, 0
    local stack = { { alt = tree.entries, depth = -1, seq = 0 } }
    while #stack > 0 do
        local node = table.remove(stack)
        if not node.visited then
            node.visited = true
            maxdepth = math.max(maxdepth, node.depth)
            maxseq = math.max(maxseq, node.seq)
            if node.seq == tree.seq_cur then
                node.cur = true
            end
            if node.depth >= 0 then
                table.insert(list, node)
                if node.cur then
                    curidx = #list
                end
            end
            if node.alt then
                for i = 1, #node.alt, 1 do
                    local child = node.alt[i]
                    child.depth = node.depth + 1
                    if not child.visited then
                        table.insert(stack, child)
                    end
                end
            end
        end
    end
    return { list = list, curidx = curidx, maxdepth = maxdepth, maxseqlen = #("" .. maxseq) }
end

local function fmt_time(time)
    local tpl = {
        { { 1, 60, },                            "just now",     "just now" },
        { { 60, 3600, },                         "a minute ago", "%d minutes ago" },
        { { 3600, 3600 * 24, },                  "an hour ago",  "%d hours ago" },
        { { 3600 * 24, 3600 * 24 * 7, },         "yesterday",    "%d days ago" },
        { { 3600 * 24 * 7, 3600 * 24 * 7 * 4, }, "a week ago",   "%d weeks ago" },
    }
    local delta = os.time() - time
    for _, v in ipairs(tpl) do
        if delta < v[1][2] then
            local value = math.floor(delta / v[1][1] + 0.5)
            return value == 1 and v[2] or v[3]:format(value)
        end
    end
    return os.date("%b %d, %Y", time)
end

function M.pick_undo()
    local buf = vim.api.nvim_get_current_buf()
    local tmp_file = vim.fn.stdpath("cache") .. "/picker-undo"
    local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.fn.writefile(buf_lines, tmp_file)
    local tmp_undo = tmp_file .. ".undo"
    vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent wundo! " .. tmp_undo)
    end)
    local tmp_buf = vim.fn.bufadd(tmp_file)
    vim.bo[tmp_buf].swapfile = false
    vim.fn.bufload(tmp_buf)
    vim.api.nvim_buf_call(tmp_buf, function()
        ---@diagnostic disable-next-line: param-type-mismatch
        pcall(vim.cmd, "silent rundo " .. tmp_undo)
    end)

    local tree = undotree()
    local pbuf = vim.api.nvim_create_buf(false, true)
    vim.bo[pbuf].filetype = "diff"
    local function text_cb(node)
        local s = ("%s %s%d"):format(
            node.cur and ">" or " ",
            string.rep("  ", node.depth),
            node.seq
        )
        local mlen = 2 + tree.maxdepth * 2 + tree.maxseqlen
        return ("%-" .. mlen + 4 .. "s %s"):format(s, fmt_time(node.time))
    end
    local function add_highlights(item, line, add_highlight)
        if item.save then
            add_highlight(0, {
                end_col = #line,
                hl_group = "PickerUndoSave",
                strict = false,
            })
        end
    end
    local function on_close(item, _opts)
        vim.api.nvim_buf_delete(pbuf, { force = true })
        vim.api.nvim_buf_delete(tmp_buf, { force = true })
        vim.fn.delete(tmp_file)
        vim.fn.delete(tmp_undo)
        if item then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("undo " .. item.seq)
            end)
        end
    end
    local diff_previous = true
    local function preview(item)
        local ei = vim.o.eventignore
        vim.o.eventignore = "all"
        local before, after = buf_lines, nil
        vim.api.nvim_buf_call(tmp_buf, function()
            vim.cmd("noautocmd silent undo " .. item.seq)
            after = vim.api.nvim_buf_get_lines(tmp_buf, 0, -1, false)
            if diff_previous then
                vim.cmd("noautocmd silent undo")
                before = vim.api.nvim_buf_get_lines(tmp_buf, 0, -1, false)
            end
        end)
        vim.o.eventignore = ei
        local diff = vim.diff(table.concat(before, "\n") .. "\n", table.concat(assert(after), "\n") .. "\n",
            { ctxlen = 4 })
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, vim.split(diff, "\n"))
        return { bufnr = pbuf }
    end
    local function toggle_preview_type(item)
        diff_previous = not diff_previous
        preview(item)
    end
    M.pick("Undo:", tree.list, on_close, {
        text_cb = text_cb,
        add_highlights = add_highlights,
        preview = preview,
        keymaps = { ["<a-p>"] = toggle_preview_type },
        select = tree.curidx,
    })
end

------------------------------------------------------------------------

function M.pick_cmd(cmd)
    M.pick(cmd .. ":", vim.fn.getcompletion(cmd .. " ", "cmdline"), function(item)
        if item then
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.schedule_wrap(vim.cmd)(cmd .. " " .. item)
        end
    end)
end

vim.api.nvim_create_user_command("Pick", function(cmd)
    if #cmd.fargs == 0 then
        M.pick_cmd("Pick")
    else
        local func = M["pick_" .. cmd.args]
        if func and type(func) == 'function' and debug.getinfo(func).nparams == 0 then
            func()
        else
            vim.api.nvim_echo({ { string.format("No picker named %q", cmd.args), "ErrorMsg" } }, false, {})
        end
    end
end, {
    nargs = '?',
    desc = "Opens picker",
    complete = function(_lead, line, col)
        local _, _, prefix = line:sub(1, col):find("%S+%s+(%S*)")
        prefix = "^pick_" .. prefix
        local candidates = {}
        for name, item in pairs(M) do
            if type(item) == "function" and name:find(prefix) and debug.getinfo(item).nparams == 0 then
                table.insert(candidates, name:sub(#"pick_" + 1))
            end
        end
        table.sort(candidates)
        return candidates
    end
})

vim.api.nvim_create_user_command("PickCmd", function(cmd)
    M.pick_cmd(cmd.args)
end, {
    nargs = 1,
    desc = "Pick CommandArg",
})

function M.setup()
    vim.ui.select = M.select
    vim.keymap.set('n', '<leader>f', M.pick_file)
    vim.keymap.set('n', '<leader>b', M.pick_buffer)
    vim.keymap.set('n', '<leader>h', M.pick_help)
    vim.keymap.set('n', '<leader>/', M.pick_grep)
    vim.keymap.set('n', '<leader>u', M.pick_undo)
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspPickers', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gd', M.pick_definition, opts("Goto definition"))
            vim.keymap.set('n', 'gD', M.pick_declaration, opts("Goto declaration"))
            vim.keymap.set('n', 'gy', M.pick_type_definition, opts("Goto type definition"))
            vim.keymap.set('n', 'gi', M.pick_implementation, opts("Goto implementation"))
            vim.keymap.set('n', '<leader>r', M.pick_reference, opts("Goto reference"))
            vim.keymap.set('n', '<leader>s', M.pick_document_symbol, opts("Open symbol picker"))
            vim.keymap.set('n', '<leader>S', M.pick_workspace_symbol, opts("Open workspace symbol picker"))
            vim.keymap.set('n', '<leader>d', M.pick_document_diagnostic, opts("Open diagnostic picker"))
            vim.keymap.set('n', '<leader>D', M.pick_workspace_diagnostic, opts("Open workspace diagnostic picker"))
        end,
    });
end

return M
