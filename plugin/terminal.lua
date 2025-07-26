local set = vim.opt_local

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", {}),
    callback = function()
        set.number = false
        set.relativenumber = false
        set.scrolloff = 0

        vim.bo.filetype = "terminal"
    end,
})
