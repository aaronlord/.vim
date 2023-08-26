require("aaronlord.set")
require("aaronlord.remap")
require("aaronlord.colorscheme")
require("aaronlord.lazy")

-- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('HighlightYank', {}),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 500,
        })
    end,
})
