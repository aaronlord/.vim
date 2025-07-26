require("codecompanion").setup({
    extensions = {
        mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
                make_vars = true,
                make_slash_commands = true,
                show_result_in_chat = true
            }
        }
    }
})

vim.keymap.set("n", "<leader>ai", "<CMD>CodeCompanionActions<CR>", { desc = "Code Companion Actions" })
