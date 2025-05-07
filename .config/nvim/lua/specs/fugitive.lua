local spec = { "tpope/vim-fugitive" }

function spec.config()
    -- workaround: fugitive is unable to detect git_dir for dotfiles repo
    vim.api.nvim_create_autocmd('BufRead', {
        group = vim.api.nvim_create_augroup('FindGitDir', {}),
        callback = function()
            local f = io.popen("git rev-parse --show-toplevel")
            if f ~= nil then
                local l = f:read("*a")
                f:close()
                vim.b.git_dir = l:sub(1, -2) .. '/.git'
            end
        end
    })

    vim.keymap.set('n', ' g', function()
        vim.cmd("G | only")
    end)
end

return spec

--[[
<space>g       open git summary

git summary:
gq              close
] ] [[          next/prev header
=               header: toggle inline diff for all files
                file: toggle inline diff
s               stage current file(s)/hunk/selection
u               unstage current file(s)/hunk/selection
-               stage/unstage current file(s)/hunk/selection
--]]
