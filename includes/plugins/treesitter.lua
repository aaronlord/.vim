require'nvim-treesitter.configs'.setup {
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
    }
}

require'treesitter-context'.setup{
  separator = '─',
}
