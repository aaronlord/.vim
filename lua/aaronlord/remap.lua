vim.g.mapleader = " "

-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Remap macro record
vim.keymap.set("n", "<leader>q", "q")
vim.keymap.set("n", "q", "<nop>")

-- Yank to clipboard
vim.keymap.set("v", "yc", [["+y]])

-- >, < tabs in/out visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Bubble sort lines
vim.keymap.set("n", "<C-k><C-k>", "ddkP")
vim.keymap.set("n", "<C-j><C-j>", "ddp")
vim.keymap.set("v", "<C-k><C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<C-j><C-j>", ":m '>+1<CR>gv=gv")

-- <C-[h, j, k, l]> navigates to the [window left, down, up, right]
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- <C-w><C-[h, l]> navigates to the previous and next tab
vim.keymap.set("n", "<C-w><C-h>", ":tabprevious<CR>")
vim.keymap.set("n", "<C-w><C-l>", ":tabnext<CR>")
