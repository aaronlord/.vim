local conf = require "telescope.config".values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local sorters = require "telescope.sorters"

local M = {}

M.search = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()

    local function get_dirty_files()
        local handle = io.popen(
            "(git status --porcelain -u | grep '^[ M?]' | awk '{print $2}'; git diff --name-only $(git merge-base HEAD main)) | sort -u",
            'r'
        )

        if not handle then return {} end

        local result = {}

        for line in handle:lines() do
            table.insert(result, line)
        end

        handle:close()

        return result
    end

    local dirty_files = get_dirty_files()

    local finder = finders.new_table {
        results = dirty_files,
        entry_maker = make_entry.gen_from_file(opts),
    }

    pickers.new(opts, {
        prompt_title = "Find Dirty Files",
        finder = finder,
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
    }):find()
end

return M
