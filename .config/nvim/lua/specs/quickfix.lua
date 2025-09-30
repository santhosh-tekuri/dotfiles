local spec = {
    "santhosh-tekuri/quickfix.nvim",
    -- dir = "~/gh/santhosh-tekuri/quickfix.nvim",
}

function spec.config()
    vim.o.quickfixtextfunc = require("quickfix").quickfixtextfunc
end

return spec
