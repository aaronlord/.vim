local tdd = require('tdd')

-- local run = function(command)
--     vim.fn.system(string.format('tmux select-window -t %q', 2))
--     vim.wait(100)
--     vim.fn.system(string.format('tmux send-keys -t %s %q C-m', 2, command))
-- end

tdd.setup({
    runners = {
        pest = {
            command = function(file, test_name)
                if test_name then
                    return string.format('magnus pest --stop-on-defect %s --filter "%s"', file, test_name)
                else
                    return string.format(
                        'magnus pest --stop-on-defect --coverage-cobertura .coverage/cobertura.single.xml %s',
                        file)
                end
            end,
            -- run_test = run,
        },
        vitest = {
            command = function(file, _, line_number)
                if line_number then
                    return string.format('magnus npm run test:run -- %s:%s', file, line_number)
                else
                    return string.format('magnus npm run test:run -- %s', file)
                end
            end,
            -- run_test = run,
        },
    },
})

-- Keybindings
vim.keymap.set("n", "<leader>tt", function()
    tdd.jump(true)
end, { desc = "Jump to test or SUT" })

vim.keymap.set("n", "<leader>tj", function()
    tdd.jump(false)
end, { desc = "Goto the sut or show all test options to select from" })

vim.keymap.set("n", "<leader>tr", function()
    tdd.clear_coverage_cache()
    tdd.run_test_file()
end, { desc = "Run the current test file" })

vim.keymap.set('n', '<leader><leader>tr', function()
    tdd.clear_coverage_cache()
    tdd.run_test()
end, { desc = "Run the current test within a file" })

vim.keymap.set('n', '<leader>tc', function()
    tdd.show_uncovered_lines('/var/www/html', '.coverage/cobertura.xml')
end, { desc = "Run the current test within a file" })

vim.keymap.set('n', '<leader><leader>tc', function()
    tdd.show_uncovered_in_current_file('/var/www/html', '.coverage/cobertura.single.xml')
end, { desc = "Show uncovered lines in current file" })

-- Clear all coverage caches
vim.keymap.set('n', '<leader>tx', function()
    tdd.clear_coverage_cache()
end, { desc = "Clear all coverage caches" })
