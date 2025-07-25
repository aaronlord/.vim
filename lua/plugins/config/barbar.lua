vim.g.barbar_auto_setup = false

require('barbar').setup({
    highlight_visible = false,
    animation = false,
    tabpages = true,
    icons = {
        button = " ",
        separator = {
            left = "▊",
        }
    }
})

vim.keymap.set("n", "<M-,>", "<CMD>BufferPrevious<CR>")
vim.keymap.set("n", "<M-.>", "<CMD>BufferNext<CR>")

vim.keymap.set("n", "<M-<>", "<CMD>BufferMovePrevious<CR>")
vim.keymap.set("n", "<M->>", "<CMD>BufferMoveNext<CR>")

vim.keymap.set("n", "<M-1>", "<CMD>BufferGoto 1<CR>")
vim.keymap.set("n", "<M-2>", "<CMD>BufferGoto 2<CR>")
vim.keymap.set("n", "<M-3>", "<CMD>BufferGoto 3<CR>")
vim.keymap.set("n", "<M-4>", "<CMD>BufferGoto 4<CR>")
vim.keymap.set("n", "<M-5>", "<CMD>BufferGoto 5<CR>")
vim.keymap.set("n", "<M-6>", "<CMD>BufferGoto 6<CR>")
vim.keymap.set("n", "<M-7>", "<CMD>BufferGoto 7<CR>")
vim.keymap.set("n", "<M-8>", "<CMD>BufferGoto 8<CR>")
vim.keymap.set("n", "<M-9>", "<CMD>BufferGoto 9<CR>")

vim.keymap.set("n", "<M-c>", "<CMD>BufferClose<CR>")
