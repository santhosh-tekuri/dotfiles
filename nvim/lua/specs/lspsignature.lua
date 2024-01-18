local spec = { "ray-x/lsp_signature.nvim" }

function spec.config()
    require("lsp_signature").setup {
        doc_lines = 0,
        hint_enable = false,
        handler_opts = {
            border = "none",
        }
    }
end

return spec
