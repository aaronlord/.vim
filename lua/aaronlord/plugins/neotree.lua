return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    keys = {
        {"<C-k><C-b>", ":Neotree toggle<cr>"},
        {"<C-k><C-f>", ":Neotree reveal<cr>"},
    },
    opts = {
        enable_diagnostics = false,
        window = {
            position = "current",
            mappings = {
                ["o"] = "open",
                ["/"] = "filter_on_submit",
            },
        },
        default_component_configs = {
            indent = {
                indent_size = 4,
            },
            name = {
                trailing_slash = true,
                use_git_status_colors = false,
                highlight = "NeoTreeFileName",
            },
            git_status = {
                symbols = {
                    -- Change type
                    added     = "+",
                    modified  = "~",
                    deleted   = "-",
                    renamed   = ">",
                    -- Status type
                    untracked = "", -- "",
                    ignored   = "", -- "",
                    unstaged  = "", -- "󰄱",
                    staged    = "", -- "",
                    conflict  = "", -- "",
                }
            },
            file_size = {
                enabled = false,
            },
            type = {
                enabled = false,
            },
            last_modified = {
                enabled = false,
            },
            created = {
                enabled = false,
            },
            symlink_target = {
                enabled = true,
            },
        },
        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
                never_show = {
                    ".git",
                    ".phplint.cache",
                    ".phpunit.cache",
                    ".phpunit.result.cache",
                    ".php-cs-fixer.cache",
                },
            }
        },
    }
}
