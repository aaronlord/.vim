local prs = require("prs")

vim.keymap.set("n", "<leader><leader>pro", prs.create, { desc = "Open a PR" })
vim.keymap.set("n", "<leader><leader>prr", prs.ready, { desc = "Mark PR as ready" })
vim.keymap.set("n", "<leader><leader>prd", prs.draft, { desc = "Mark PR as draft" })
vim.keymap.set("n", "<leader><leader>prv", prs.view, { desc = "View PR in browser" })
vim.keymap.set("n", "<leader><leader>prq", prs.commented_files, { desc = "Load files with comments to quicklist" })
