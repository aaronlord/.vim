require("nvim-treesitter.configs").setup({
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
        "markdown_inline",
        "php",
        "rust",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
    },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    modules = {},
})

vim.treesitter.language.register('markdown', 'mdx')

vim.filetype.add({
    extension = {
        astro = "astro",
        mdx = 'mdx'
    }
})
