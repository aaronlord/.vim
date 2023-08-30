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
}
