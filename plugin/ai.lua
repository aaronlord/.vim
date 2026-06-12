local ai = require("ai")

-- Target tmux pane/window. Change if needed (e.g. "1.2", ":.+" etc).
ai.tmux_target = 3

vim.keymap.set("n", "<leader>ai", ai.open_add_buffer, { desc = "Add current buffer to AI prompt queue" })

vim.keymap.set("v", "<leader>ai", function()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    ai.open_add_buffer({ start_line = start_line, end_line = end_line })
end, { desc = "Add selected lines to AI prompt queue" })

vim.keymap.set("n", "<leader>aic", function()
    ai.queue_clear()
    vim.notify("AI queue cleared", vim.log.levels.INFO)
end, { desc = "Clear AI prompt queue" })

vim.keymap.set("n", "<leader><leader>ai", ai.open_review_buffer, { desc = "Review and send AI prompt queue" })

vim.keymap.set("n", "<leader>air", ai.restore_prompt, { desc = "Restore last sent AI prompt" })
