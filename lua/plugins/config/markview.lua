local presets = require("markview.presets");

require("markview").setup({
    markdown = {
        headings = presets.headings.glow,
        horizontal_rules = presets.horizontal_rules.dashed,
    },
    preview = {
        enable = true,
        enable_hybrid_mode = true,
        icon_provider = "devicons",
        filetypes = {
            "markdown",
            "codecompanion",
        },
        ignore_buftypes = { "nofile" },
    },
})
