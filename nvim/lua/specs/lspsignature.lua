local spec = { "ray-x/lsp_signature.nvim", tag = "v0.2.0" }

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
