return {
    lazy = false,
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
        {
            "mason-org/mason.nvim",
            opts = {},
        },
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("plugins.config.mason")
    end,
}
