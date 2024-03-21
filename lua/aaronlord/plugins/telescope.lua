return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope-live-grep-args.nvim"
    },
    keys = {
        {"<C-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>"},
        -- {"<C-f>", "<cmd>lua require('telescope.builtin').live_grep()<cr>"},
        {"<C-f>", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>"},
        {"<C-s>", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>"},
        {"<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>"},
        {"<leader>:", "<cmd>lua require('telescope.builtin').command_history()<cr>"},
        {"<leader>/", "<cmd>lua require('telescope.builtin').search_history()<cr>"},
        {"<leader>ht", "<cmd>lua require('telescope.builtin').help_tags()<cr>"},
    },
    config = function()
        require('telescope').setup({
            pickers = {
                find_files = {
                    hidden = true,
                    no_ignore = true,
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
                    "^.git",
                    "^.php-cs-fixer.cache",
                    "^.phplint.cache",
                    "^.phpunit.cache",
                    "^.phpunit.result.cache",
                    "^node_modules",
                    "^public",
                    "^storage",
                    "vendor",
                }
            }
        })
    end
}
