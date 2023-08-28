return {
    "romgrk/barbar.nvim",
    lazy = false,
    keys = {
        -- Move
        { "<A-,>", "<Cmd>BufferPrevious<CR>", { noremap = true, silent = true } },
        { "<A-.>", "<Cmd>BufferNext<CR>", { noremap = true, silent = true } },

        -- Re-order
        { "<A-<>", "<Cmd>BufferMovePrevious<CR>", { noremap = true, silent = true } },
        { "<A->>", "<Cmd>BufferMoveNext<CR>", { noremap = true, silent = true } },

        -- Jump
        { "<A-1>", "<Cmd>BufferGoto 1<CR>", { noremap = true, silent = true } },
        { "<A-2>", "<Cmd>BufferGoto 2<CR>", { noremap = true, silent = true } },
        { "<A-3>", "<Cmd>BufferGoto 3<CR>", { noremap = true, silent = true } },
        { "<A-4>", "<Cmd>BufferGoto 4<CR>", { noremap = true, silent = true } },
        { "<A-5>", "<Cmd>BufferGoto 5<CR>", { noremap = true, silent = true } },
        { "<A-6>", "<Cmd>BufferGoto 6<CR>", { noremap = true, silent = true } },
        { "<A-7>", "<Cmd>BufferGoto 7<CR>", { noremap = true, silent = true } },
        { "<A-8>", "<Cmd>BufferGoto 8<CR>", { noremap = true, silent = true } },
        { "<A-9>", "<Cmd>BufferGoto 9<CR>", { noremap = true, silent = true } },
        { "<A-0>", "<Cmd>BufferLast<CR>", { noremap = true, silent = true } },

        -- Close
        { "<A-c>", "<Cmd>BufferClose<CR>", { noremap = true, silent = true } },

        -- Pin
        -- { "<A-p>", "<Cmd>BufferPin<CR>", {  noremap = true, silent = true } },
    },
    config = function () 
        vim.g.barbar_auto_setup = false

        require('barbar').setup({
            highlight_visible = false,
            animation = false,
            tabpages = true,
            icons = {
                button = " ",
                pinned = {
                    button = "📍",
                    filename = true
                },
                separator = {
                    left = "▊",
                    right = "▊"
                }
            }
        })
    end
}
