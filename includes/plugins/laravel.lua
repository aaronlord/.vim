require('laravel').setup()

require('telescope').load_extension 'laravel'

vim.keymap.set('n', '<leader>la', ':Laravel artisan<cr>', {})
vim.keymap.set('n', '<leader>lr', ':Laravel routes<cr>', {})
vim.keymap.set('n', '<leader>lt', ':Artisan tinker<cr>', {})
vim.keymap.set('v', '<leader>lt', function()
    require("laravel").app.sendToTinker()
end, {})

vim.keymap.set('n', '<leader>tt', function ()
    require('laravel.artisan').run({'test --compact '..vim.fn.expand('%')}, 'buffer')
end, {})

-- vim.api.nvim_create_user_command('Rentora', function ()
    -- require('laravel.artisan').run({"serve"})
    -- require('laravel.artisan').run({'queue:listen'}, 'persist')
    -- require('laravel.yarn').run({"dev"}, "persist")
-- end, {})
