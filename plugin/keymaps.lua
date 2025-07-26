-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Remap macro recording away from q
vim.keymap.set("n", "<leader><leader>r", "q")
vim.keymap.set("n", "q", "<nop>")

-- >, < tabs in/out visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Bubble sort lines
vim.keymap.set("v", "<C-k><C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<C-j><C-j>", ":m '>+1<CR>gv=gv")

-- Easier tab navigation
vim.keymap.set("n", "<C-w><C-h>", ":tabprevious<CR>")
vim.keymap.set("n", "<C-w><C-l>", ":tabnext<CR>")

-- Resize splits
vim.keymap.set("n", "<M-n>", "<C-w>5<")
vim.keymap.set("n", "<M-w>", "<C-w>5>")
vim.keymap.set("n", "<M-t>", "<C-W>+")
vim.keymap.set("n", "<M-s>", "<C-W>-")

-- <M-j> and <M-k> moves up and down in the quickfix list
vim.keymap.set("n", "<M-j>", ":cnext<CR>")
vim.keymap.set("n", "<M-k>", ":cprev<CR>")
