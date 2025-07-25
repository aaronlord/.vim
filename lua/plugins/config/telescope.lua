require("telescope").setup({
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true,
        },
    },
    defaults = require("telescope.themes").get_ivy({
        file_ignore_patterns = {
            "^.git",
            "^.php-cs-fixer.cache",
            "^.phplint.cache",
            "^.phpunit.cache",
            "^.phpunit.result.cache",
            "^.obsidian",
            "^.DS_Store",
            "^.coverage",
            "^node_modules",
            "^public",
            "^storage",
            "vendor",
        }
    }),
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
        },
    }
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<M-p>", builtin.oldfiles)
vim.keymap.set("n", "<leader>b", builtin.buffers)
vim.keymap.set("n", "<leader>:", builtin.command_history)
vim.keymap.set("n", "<leader>/", builtin.search_history)
vim.keymap.set("n", "<leader>h", builtin.help_tags)
vim.keymap.set("n", "<leader>j", builtin.jumplist)
vim.keymap.set("n", "<leader>q", builtin.quickfixhistory)
vim.keymap.set("n", "<leader>r", builtin.registers)

-- LSP
vim.keymap.set("n", "<C-]>", builtin.lsp_definitions)
vim.keymap.set("n", "g0", builtin.lsp_document_symbols)
vim.keymap.set("n", "grr", builtin.lsp_references)
vim.keymap.set("n", "gri", builtin.lsp_implementations)

vim.keymap.set("n", "<leader>d", function()
    builtin.diagnostics({
        bufnr = 0,
    })
end)

vim.keymap.set("n", "<C-f>", function()
    require("plugins.config.telescope.rg").search()
end)

vim.keymap.set("n", "<leader>g", function()
    require("plugins.config.telescope.dirty").search()
end)

vim.keymap.set("n", "<leader>vc", function()
    builtin.find_files({
        cwd = vim.fn.stdpath("config")
    })
end)
