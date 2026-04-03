vim.pack.add { "https://github.com/santhosh-tekuri/quickfix.nvim" }
-- dir = "~/gh/santhosh-tekuri/quickfix.nvim",

vim.o.quickfixtextfunc = require("quickfix").quickfixtextfunc
