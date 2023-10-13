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
                "astro",
                "bash",
                "dockerfile",
                "html",
                "javascript",
                "json",
                "lua",
                "php",
                "rust",
                "tsx",
                "typescript",
                "vim",
                "vue",
                "yaml",
            },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        })

        vim.filetype.add({
            extension = {
                astro = "astro"
            }
        })
    end
}
