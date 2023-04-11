require('telescope').setup{
  defaults = {
    mappings = {
      n = {
          ['<C-d>'] = require('telescope.actions').delete_buffer
      },
      i = {
        ['<C-h>'] = 'which_key',
        ['<C-d>'] = require('telescope.actions').delete_buffer
      }
    }
  }
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<c-p>', builtin.find_files, {})
vim.keymap.set('n', '<c-f>', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
