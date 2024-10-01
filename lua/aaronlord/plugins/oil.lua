return {
    'stevearc/oil.nvim',
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    lazy = false,
    keys = {
        { '-', '<CMD>:Oil<CR>' },
    },
    opts = {
        default_file_explorer = false,
        view_options = {
            show_hidden = true,
        },
    },
}
