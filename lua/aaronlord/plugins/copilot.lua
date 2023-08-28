return {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function () 
        vim.g.copilot_no_tab_map = true

        vim.api.nvim_set_keymap("i", "<A-`>", "copilot#Accept('<CR>')", { expr = true, silent = true })
    end
}
