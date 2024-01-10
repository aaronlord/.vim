local extra = require("aaronlord.helpers").extra(...)

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

        if extra then
            extra.config()
        end
    end
}
