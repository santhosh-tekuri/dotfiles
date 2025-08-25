vim.opt.number = true         -- show line number for each line
vim.opt.relativenumber = true -- show relative line number for each line
vim.opt.termguicolors = true  -- enable RGB colors
vim.opt.expandtab = true      -- convert tabs to spaces
vim.opt.shiftwidth = 4        -- no of spaces inserted for each indentation
vim.opt.tabstop = 4           -- no of spaces inserted for tab
vim.opt.signcolumn = "yes"    -- always show signcolumn
vim.opt.wrap = false          -- disable line wrap
vim.opt.laststatus = 0        -- never show status line
vim.opt.splitbelow = true     -- put new window below the split
vim.opt.splitright = true     -- put new window right to the split
vim.opt.inccommand = "split"  -- show substitute preview in split
vim.opt.ignorecase = true     -- prefer case-insensitive search UNLESS \C prefix
vim.opt.smartcase = true      -- override ignorecase when pattern has uppercase
vim.opt.scrolloff = 3         -- min lines to keep above/below cursor
vim.opt.confirm = true        -- show dialog for confirmation
vim.opt.undofile = true       -- save undo history to undo file

-- use vertical split for diff
vim.opt.diffopt:append 'vertical'

-- show trailing whitespaces
vim.opt.listchars = { tab = '  ', trail = '␣' }
vim.opt.list = true

-- fill deleted lines with spaces in diff-mode
vim.opt.fillchars:append { diff = " " }

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
        },
    },
    severity_sort = true,
})
