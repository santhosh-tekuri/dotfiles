vim.opt.number = true         -- show line number for each line
vim.opt.relativenumber = true -- show relative line number for each line
vim.opt.termguicolors = true  -- enable RGB colors
vim.opt.expandtab = true      -- convert tabs to spaces
vim.opt.shiftwidth = 4        -- no of spaces inserted for each indentation
vim.opt.tabstop = 4           -- no of spaces inserted for tab
vim.opt.signcolumn = "yes"    -- always show signcolumn
vim.opt.wrap = false          -- disable line wrap
vim.opt.laststatus = 3        -- single statusline for all splits
vim.opt.splitbelow = true     -- put new window below the split
vim.opt.splitright = true     -- put new window right to the split
vim.opt.inccommand = "split"  -- show substitute preview in split
vim.opt.ignorecase = true     -- prefer case-insensitive search UNLESS \C prefix
vim.opt.smartcase = true      -- override ignorecase when pattern has uppercase
vim.opt.scrolloff = 3         -- min lines to keep above/below cursor
vim.opt.confirm = true        -- show dialog for confirmation

-- show whitespace using :set list
vim.opt.listchars = { space = '.', tab = '>-', trail = '.' }

-- fill deleted lines with spaces in diff-mode
vim.opt.fillchars:append { diff = " " }
