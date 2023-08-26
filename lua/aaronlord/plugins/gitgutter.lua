return {
    "airblade/vim-gitgutter",
    event = "BufReadPre",
    config = function ()
        vim.g.gitgutter_map_keys = 0
    end
}
