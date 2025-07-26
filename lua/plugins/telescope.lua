return {
    lazy = false,
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
        require("plugins.config.telescope")
    end,
}
