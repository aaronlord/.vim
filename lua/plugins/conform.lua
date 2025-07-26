return {
    lazy = false,
    "stevearc/conform.nvim",
    init = function()
        -- If you want the formatexpr, here is the place to set it
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    config = function()
        require("plugins.config.conform")
    end,
}
