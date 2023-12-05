return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context"
    },
    build = ":TSUpdate",
    event = "BufReadPre",
    config = function ()
        local configs = require("nvim-treesitter.configs")
        local parsers = require("nvim-treesitter.parsers")

        configs.setup({
            ensure_installed = {
                "astro",
                "bash",
                "dockerfile",
                "html",
                "http",
                "javascript",
                "json",
                "lua",
                "markdown",
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

        -- parsers.filetype_to_parsername.mdx = "markdown"

        vim.treesitter.language.register('markdown', 'mdx')

        vim.filetype.add({
            extension = {
                astro = "astro",
                mdx = 'mdx'
            }
        })
    end
}
