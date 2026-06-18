local ai = require("ai")

ai.tmux_target = 3

-- ─── <leader>ai ───────────────────────────────────────────────────────────────
-- Visual: send selection to a new Pi pane (Pi rewrites the highlighted block)
-- Normal: add current file context to the queue

vim.keymap.set("v", "<leader>ai", function()
    ai.open_visual_task_buffer()
end, { desc = "AI: send visual selection to new Pi pane" })

vim.keymap.set("n", "<leader>ai", function()
    ai.open_add_buffer()
end, { desc = "AI: add to queue" })

-- ─── <leader><leader>ai — Review queue and send ───────────────────────────────
-- <leader>air (restore last prompt) is available inside the review buffer only

vim.keymap.set("n", "<leader><leader>ai", ai.open_review_buffer,
    { desc = "AI: review queue and send to agent" })

-- ─── Visual task review (cursor must be inside a ready task) ─────────────────

vim.keymap.set("n", "<leader>aij", ai.jump_to_task_pane,
    { desc = "AI: jump to the tmux pane for the task at cursor" })

vim.keymap.set("n", "<leader>air", ai.review_visual_task,
    { desc = "AI: diff review for visual task at cursor" })

-- ─── Commands ─────────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("AIClear",
    function()
        ai.queue_clear(); vim.notify("[ai] Queue cleared", vim.log.levels.INFO)
    end,
    { desc = "Clear AI prompt queue" })

vim.api.nvim_create_user_command("AIClearTasks",
    function() ai.clear_all_visual_tasks() end,
    { desc = "Clear all in-flight Pi visual tasks" })

vim.api.nvim_create_user_command("AIModel",
    function() ai.pick_model() end,
    { desc = "Pick AI model" })


