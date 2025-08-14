vim.keymap.set("n", "<leader>x", "<CMD>.lua<CR>", {
    desc = "Execute the current line as Lua code",
    buffer = 0,
    noremap = true,
    silent = true
})

vim.keymap.set("n", "<leader><leader>x", "<CMD>source %<CR>", {
    desc = "Execute the current file as Lua code",
    buffer = 0,
    noremap = true,
    silent = true
})
