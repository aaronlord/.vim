require('telescope').setup{
    pickers = {
        find_files = {
            hidden = true,
        },
    },
    defaults = {
        mappings = {
            n = {
                ['<C-d>'] = require('telescope.actions').delete_buffer
            },
            i = {
                ['<C-h>'] = 'which_key',
                ['<C-d>'] = require('telescope.actions').delete_buffer
            }
        },
        file_ignore_patterns = {
            ".git",
            "node_modules",
            "storage",
            "vendor",
        }
    }
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<c-p>', builtin.find_files, {})
vim.keymap.set('n', '<c-f>', builtin.live_grep, {})
vim.keymap.set('n', '<c-s>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>:', builtin.command_history, {})
vim.keymap.set('n', '<leader>/', builtin.search_history, {})
