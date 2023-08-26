return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context"
    },
    build = ":TSUpdate",
    event = "BufReadPre", 
    config = function () 
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "bash",
                "dockerfile",
                "html",
                "javascript",
                "json",
                "lua",
                "php",
                "rust",
                "vim",
                "yaml",
                "vue",
            },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        })
    end
}
