return {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function ()
        local colors = require("cyberdream.colors").default

        require('cyberdream').setup({
            theme = {
                colors = {
                    bg = "#1c1c1c",
                    bgAlt = "#232323",
                    bgHighlight = "#3c3c3c",
                },
                highlights = {
                    ColorColumn = { bg = colors.bgAlt },
                    CursorLine = { bg = colors.bgAlt },
                    CursorColumn = { bg = colors.bgAlt },

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
    end
}
