vim.keymap.set("n", "<leader>tt", function()
    require("tdd").jump(true)
end, { desc = "Goto the sut or test if there's only one, otherwise show all options to select from" })

vim.keymap.set("n", "<leader>tj", function()
    require("tdd").jump(false)
end, { desc = "Goto the sut or show all test options to select from" })

vim.keymap.set("n", "<leader>tr", function()
    require("tdd").when_test(function(file)
        vim.fn.system(string.format("tmux send-keys -t %s 'magnus pest %s' C-m", 2, file))
    end)
end, { desc = "Run the current test in the second tmux pane" })
