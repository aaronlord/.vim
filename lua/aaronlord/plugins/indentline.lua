return {
    "Yggdroot/indentLine",
    event = "BufReadPre",
    config = function ()
        -- vim.g.indentLine_char_list = {"|", "¦", "┆", "┊"}
        vim.g.indentLine_fileTypeExclude = {"http", "json", "markdown", "neo-tree"}
    end
}
