local spec = { "stevearc/conform.nvim" }

function spec.config()
    require("conform").setup {
        format_on_save = {
            lsp_format = "prefer",
        },
        formatters_by_ft = {
            python = { "black" },
        },
    }
end

return spec
