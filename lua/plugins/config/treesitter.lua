require('nvim-treesitter').install({
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
})

vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > max_filesize then return end
        pcall(vim.treesitter.start, args.buf)
    end,
})

vim.treesitter.language.register('markdown', 'mdx')

vim.filetype.add({
    extension = {
        astro = "astro",
        mdx = 'mdx',
    },
})
