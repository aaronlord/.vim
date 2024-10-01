return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
      "BufReadPre " .. vim.fn.expand "~" .. "/SynologyDrive/Documents/Obsidian/Work/**.md",
      "BufReadPre " .. vim.fn.expand "~" .. "/SynologyDrive/Documents/Obsidian/Personal/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "personal",
                path = "~/SynologyDrive/Documents/Obsidian/Personal",
            },
            {
                name = "work",
                path = "~/SynologyDrive/Documents/Obsidian/Work",
            },
        },
    },
}
