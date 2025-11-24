require("hardtime").setup({
    restriction_mode = "hint",
    hints = {
        ["[^fFtT]ko"] = {
            message = function()
                return "use O instead of ko"
            end,
            length = 3
        },
        ["[^fFtT]0w"] = {
            message = function()
                return "use ^ instead of 0w"
            end,
        },

    }
})
