vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    hijack_cursor = true,
    system_open = {
        cmd = "open",
    },
    view = {
        width = 30,
        -- adaptive_size = true,
    },
    renderer = {
        group_empty = true,
        icons = {
            show = {
                git = false,
                file = true,
                folder = false,
                folder_arrow = true,
            },
            glyphs = {
                bookmark = "🔖",
                folder = {
                    arrow_closed = "⏵",
                    arrow_open = "⏷",
                },
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "⌥",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "⊖",
                    ignored = "◌",
                },
            },
        },
    },
    filters = {
        dotfiles = true,
    },
})

vim.keymap.set('n', '<c-k><c-b>', ':NvimTreeFocus<cr>', {noremap = true, silent = true})
vim.keymap.set('n', '<c-k><c-f>', ':NvimTreeFindFile<cr>', {noremap = true, silent = true})
