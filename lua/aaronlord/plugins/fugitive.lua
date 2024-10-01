return {
    "tpope/vim-fugitive",
    dependencies = {
        "tpope/vim-rhubarb", -- GitHub
        "shumphrey/fugitive-gitlab.vim", -- GitLab
    },
    cmd = {
        "G", "Git", "GRemove", "GDelete", "GMove", "GRename", "GBrowse",
        "Gdiffsplit", "Ghdiffsplit", "Gvdiffsplit", "Gclog",
    },
    config = function ()
        vim.keymap.set("n", "g,", "<cmd>diffget //2<cr>")
        vim.keymap.set("n", "g.", "<cmd>diffget //3<cr>")

        vim.g.fugitive_gitlab_domains = {
            "gitlab.vctools.co.uk"
        }
    end
}
