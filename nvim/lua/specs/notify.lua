local spec = { "rcarriga/nvim-notify" }

function spec.config()
    vim.notify = require("notify")
end

return spec
