local ai = require("ai")

-- Target tmux pane/window. Change if needed (e.g. "1.2", ":.+" etc).
ai.tmux_target = 3

vim.keymap.set("n", "<leader>ai", ai.open_prompt_buffer, { desc = "Open Copilot prompt buffer" })

vim.keymap.set("v", "<leader>ai", function()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    ai.open_prompt_buffer({ start_line = start_line, end_line = end_line })
end, { desc = "Open Copilot prompt buffer with selected lines" })
