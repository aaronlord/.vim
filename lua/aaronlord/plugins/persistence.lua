return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
    },
    keys = {
        { "<leader>l", function() require("persistence").load() end, desc = "Restore Session" },
        -- { "<leader>ll", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    },
}
