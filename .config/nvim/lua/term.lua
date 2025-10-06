local function terminals()
    return vim.tbl_filter(function(buf)
        return vim.bo[buf].buftype == "terminal" and vim.fn.bufloaded(buf) == 1
    end, vim.api.nvim_list_bufs())
end

local function new_terminal(name)
    vim.cmd.terminal(vim.o.shell)
    vim.cmd("file term://" .. name)
    vim.api.nvim_set_option_value("buflisted", false, { buf = 0 })
    vim.api.nvim_set_option_value("modified", true, { buf = 0 })
end

local lastTerm = nil
local function open_terminal()
    local buf = nil
    if lastTerm ~= nil and vim.fn.bufloaded(lastTerm) == 1 then
        buf = lastTerm
    else
        local terms = terminals()
        if #terms > 0 then
            buf = terms[1]
        end
    end
    if buf == nil then
        buf = vim.api.nvim_create_buf(false, true)
    end
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = vim.o.columns,
        height = vim.o.lines - vim.o.cmdheight,
        row = 0,
        col = 0,
        style = "minimal",

    })
    if vim.bo[buf].buftype ~= "terminal" then
        new_terminal("default")
    end
    vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = win })
end

vim.keymap.set({ "n", "t" }, "<c-/>", function()
    if vim.bo.buftype == "terminal" then
        lastTerm = vim.api.nvim_get_current_buf()
        vim.cmd("close")
    else
        open_terminal()
    end
end, { desc = "toggle terminal" })

local function go_to_term(n)
    local terms = terminals()
    if #terms == 1 then
        return
    end
    local cur = vim.api.nvim_get_current_buf()
    for i, buf in ipairs(terms) do
        if buf == cur then
            i = i + n
            if i == 0 then
                i = #terms
            elseif i > #terms then
                i = 1
            end
            vim.api.nvim_win_set_buf(0, terms[i])
            return
        end
    end
end

local function set_keymaps(mode, buf)
    vim.keymap.set(mode, "<c-n>", function()
        local name = vim.fn.input("name: ")
        if name ~= "" then
            new_terminal(name)
        end
    end, { buffer = buf, desc = "create new terminal" })

    vim.keymap.set(mode, "<c-h>", function()
        go_to_term(-1)
    end, { buffer = buf, desc = "go to prev terminal" })

    vim.keymap.set(mode, "<c-l>", function()
        go_to_term(1)
    end, { buffer = buf, desc = "go to next terminal" })
end

set_keymaps("t")

vim.keymap.set("t", "<c-]>", "<c-\\><c-n>", { desc = "return to normal mode" })

vim.keymap.set({ "n", "t" }, "<c-;>", function()
    local function open(buf)
        if vim.bo.buftype == 'terminal' then
            vim.api.nvim_win_set_buf(0, buf)
        else
            lastTerm = buf
            open_terminal()
        end
    end

    local buffers = vim.fn.getbufinfo({ bufloaded = 1 })
    table.sort(buffers, function(a, b)
        return a.lastused > b.lastused
    end)
    local items = {}
    for _, bufinfo in ipairs(buffers) do
        if vim.bo[bufinfo.bufnr].buftype == "terminal" and vim.api.nvim_get_current_buf() ~= bufinfo.bufnr then
            table.insert(items, bufinfo)
        end
    end
    if #items == 0 then
        vim.api.nvim_echo({ { "No terminal to select", "WarningMsg" } }, false, {})
    elseif #items == 1 then
        open(items[1].bufnr)
    else
        vim.ui.select(items, {
            prompt = "Terminal:",
            format_item = function(item)
                return vim.fn.fnamemodify(item.name, ":t")
            end
        }, function(item)
            if item ~= nil then
                open(item.bufnr)
            end
        end)
    end
end, { desc = "pick terminal" })

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.cmd.startinsert()
        set_keymaps("n", 0)
    end
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        if vim.bo.buftype == 'terminal' then
            vim.schedule(vim.cmd.startinsert)
        end
    end
})

vim.api.nvim_create_autocmd('TermClose', {
    desc = "explicity close terminal",
    callback = function(ctx)
        vim.cmd.stopinsert()
        vim.keymap.set('n', 'q', function()
            local buf = vim.api.nvim_get_current_buf()
            go_to_term(1)
            vim.api.nvim_buf_delete(buf, {})
        end, { buffer = 0 })
        vim.api.nvim_create_autocmd('TermEnter', {
            desc = "prevent terminal mode",
            callback = function()
                vim.cmd.stopinsert()
            end,
            buffer = ctx.buf,
        })
    end,
    nested = true,
})

vim.keymap.set("n", "<leader>Q", function()
    -- check if any process is running in termimals
    local termCount = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" and vim.fn.bufloaded(buf) == 1 then
            termCount = termCount + 1
            local pid = vim.b[buf].terminal_job_pid
            local handle = io.popen("pgrep -P " .. pid)
            if handle ~= nil then
                local child_pids_string = handle:read("*a")
                handle:close()
                if #child_pids_string > 0 then
                    vim.api.nvim_echo({ { vim.fn.bufname(buf) .. " has running process", "ErrorMsg" } }, false, {})
                    lastTerm = buf
                    return
                end
            end
        end
    end

    if termCount > 0 then
        vim.api.nvim_echo({ { "Terminal(s) found.", "WarningMsg" } }, false, {})
        return
    end

    -- detach if remoteUI else quit
    for _, arg in ipairs(vim.v.argv) do
        if arg == "--embed" then
            vim.cmd.quit()
            return
        end
    end
    vim.cmd.detach()
end, { desc = "safe exit" })
