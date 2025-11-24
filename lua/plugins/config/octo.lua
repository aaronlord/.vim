local colors = require("cyberdream.colors").default

require("octo").setup({
    enable_builtin = true,
    default_merge_method = "squash",
    colors = { -- used for highlight groups (see Colors section below)
        white = '#ffffff',
        grey = colors.grey,
        black = '#000000',
        red = colors.red,
        dark_red = colors.magenta,
        green = colors.green,
        dark_green = colors.green,
        yellow = colors.yellow,
        dark_yellow = colors.yellow,
        blue = colors.blue,
        dark_blue = colors.blue,
        purple = colors.purple,
    },
})
