local spec = {
    "santhosh-tekuri/picker.nvim",
    -- dir = "~/gh/santhosh-tekuri/picker.nvim",
}

function spec.config()
    local m = require("picker")
    vim.ui.select = m.select
    vim.keymap.set('n', '<leader>f', m.pick_file)
    vim.keymap.set('n', '<leader>b', m.pick_buffer)
    vim.keymap.set('n', '<leader>h', m.pick_help)
    vim.keymap.set('n', '<leader>/', m.pick_grep)
    vim.keymap.set('n', '<leader>u', m.pick_undo)
    vim.keymap.set('n', '<leader>q', m.pick_qfitem)
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspPickers', {}),
        callback = function(ev)
            local function opts(desc)
                return { buffer = ev.buf, desc = desc }
            end
            vim.keymap.set('n', 'gd', m.pick_definition, opts("Goto definition"))
            vim.keymap.set('n', 'gD', m.pick_declaration, opts("Goto declaration"))
            vim.keymap.set('n', 'gy', m.pick_type_definition, opts("Goto type definition"))
            vim.keymap.set('n', 'gi', m.pick_implementation, opts("Goto implementation"))
            vim.keymap.set('n', '<leader>r', m.pick_reference, opts("Goto reference"))
            vim.keymap.set('n', '<leader>s', m.pick_document_symbol, opts("Open symbol picker"))
            vim.keymap.set('n', '<leader>S', m.pick_workspace_symbol, opts("Open workspace symbol picker"))
            vim.keymap.set('n', '<leader>d', m.pick_document_diagnostic, opts("Open diagnostic picker"))
            vim.keymap.set('n', '<leader>D', m.pick_workspace_diagnostic, opts("Open workspace diagnostic picker"))
        end,
    });
end

return spec
