local plan = require("plan")

-- ─── :Plans ───────────────────────────────────────────────────────────────────
-- Browse existing plans or create a new one by typing a name.

vim.api.nvim_create_user_command("Plan", function()
    plan.pick()
end, { desc = "Browse or create plans" })

-- ─── :PlanDeactivate ──────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("PlanDeactivate", function()
    plan.deactivate()
end, { desc = "Deactivate the current plan" })

-- ─── <leader>ai (normal mode) ─────────────────────────────────────────────────
-- Active plan  → append current file reference to ARD, open ARD at that position.
-- No active plan → fall back to the existing ai queue behaviour.

vim.keymap.set("n", "<leader>ai", function()
    plan.handle_leader_ai()
end, { desc = "AI: add file reference to active plan (or queue)" })
