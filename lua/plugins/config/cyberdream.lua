local colors = require("cyberdream.colors").default

require("cyberdream").setup({
  italic_comments = true,
  theme = {
    colors = {
      bg = "#1c1c1c",
      bgAlt = "#232323",
      bgHighlight = "#3c3c3c",
    },
    highlights = {
      BufferTabpages = { fg = colors.fg, bg = colors.bg },
      BufferTabpageFill = { fg = colors.fg, bg = colors.bg },
      BufferCurrent = { fg = colors.pink, bg = colors.bg },
      BufferCurrentMod = { fg = colors.pink },
      BufferCurrentModBtn = { fg = colors.pink },
      BufferCurrentSign = { fg = colors.pink, bg = colors.bg },
      BufferInactiveSign  = { fg = colors.bgHighlight },
      GitGutterAdd = { fg = colors.green },
      GitGutterChange = { fg = colors.yellow },
      GitGutterDelete = { fg = colors.red },
    },
  },
})

vim.cmd[[colorscheme cyberdream]]

vim.cmd("highlight ColorColumn ctermbg=0 guibg=#1f2021")
vim.cmd("highlight CursorLine ctermbg=0 guibg=#1f2021")
vim.cmd("highlight CursorColumn ctermbg=0 guibg=#1f2021")

