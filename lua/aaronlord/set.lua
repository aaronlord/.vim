local extra = require("aaronlord.helpers").extra(...)

vim.opt.guicursor = ""

vim.g.have_nerd_font = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.cursorline = true
vim.opt.laststatus = 2

vim.opt.conceallevel = 0

vim.opt.list = true
vim.opt.listchars = {
    tab = ". ",
    trail = ".",
    nbsp = ".",
    precedes = "<",
    extends = ">",
}

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80,120"

if extra then
    extra()
end
