return {
    "rachartier/tiny-inline-diagnostic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("plugins.config.tiny-inline-diagnostics")
    end,
}
