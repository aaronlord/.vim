require("persistence").setup({
    options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
        "globals",
        "skiprtp"
    },
    -- Restore barbar
    pre_save = function()
        vim.api.nvim_exec_autocmds('User', {
            pattern = 'SessionSavePre'
        })
    end,
})

vim.keymap.set("n", "<leader>l", function()
    require("persistence").load()
end, { desc = "Restore Session" })
