vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.blade.php" },
    command = "set ft=html",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.conf.template" },
    command = "set ft=nginx",
})
