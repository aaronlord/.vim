local M = {}

-- ─── State ────────────────────────────────────────────────────────────────────

M.active = nil -- plan name or nil

-- ─── Paths ────────────────────────────────────────────────────────────────────

function M.project_root()
    local dir = vim.fn.getcwd()
    local check = dir
    while check ~= "/" do
        if vim.fn.isdirectory(check .. "/.git") == 1 then return check end
        check = vim.fn.fnamemodify(check, ":h")
    end
    return dir
end

function M.plans_dir()
    return M.project_root() .. "/.plans"
end

function M.plan_dir(name)
    return M.plans_dir() .. "/" .. (name or M.active)
end

function M.ard_path(name)
    return M.plan_dir(name or M.active) .. "/ard.md"
end

function M.prd_path(name)
    return M.plan_dir(name or M.active) .. "/prd.md"
end

-- ─── List ─────────────────────────────────────────────────────────────────────

function M.list_plans()
    local dir = M.plans_dir()
    if vim.fn.isdirectory(dir) ~= 1 then return {} end
    local plans = {}
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return {} end
    while true do
        local name, typ = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if typ == "directory" then table.insert(plans, name) end
    end
    table.sort(plans)
    return plans
end

-- ─── Scaffold ─────────────────────────────────────────────────────────────────

local prd_template = [[
# PRD: %s

_Status: draft_

## Problem Statement

<!-- What problem is being solved? From the user's perspective. -->

## Solution

<!-- What we are building. High-level, from the user's perspective. -->

## User Stories

<!-- Numbered list: As a {actor}, I want {feature}, so that {benefit}. -->

## Out of Scope

## Further Notes

]]

local ard_template = [[
# ARD: %s

_Status: draft_

## Design Notes

<!-- How this will work. Think out loud — alternatives, constraints, rough approach. -->

## Code Structure

<!-- Sketch the module/layer structure. Name commands, handlers, jobs, repos as specifically as you can. -->

```
Module/
  Application/
    Commands/
    DTOs/
    Repositories/
  Domain/
    Aggregates/
  Infrastructure/
    Jobs/
    Repositories/
  Presentation/
```

## Implementation Decisions

<!-- Key decisions already made: module boundaries, interfaces, schema changes, ADRs. -->

## Testing Decisions

<!-- What tests assert, which seams are test boundaries, prior art in the codebase. -->

## Open Questions

<!-- Things to resolve before or during implementation. Starting point for /review-plan. -->

## Out of Scope

## References

]]

function M.scaffold(name)
    local dir = M.plan_dir(name)
    vim.fn.mkdir(dir .. "/tasks", "p")

    local prd = M.prd_path(name)
    if vim.fn.filereadable(prd) == 0 then
        local f = io.open(prd, "w")
        if f then f:write(string.format(prd_template, name)); f:close() end
    end

    local ard = M.ard_path(name)
    if vim.fn.filereadable(ard) == 0 then
        local f = io.open(ard, "w")
        if f then f:write(string.format(ard_template, name)); f:close() end
    end
end

-- ─── Activate ─────────────────────────────────────────────────────────────────

function M.activate(name)
    name = vim.trim(name)
    if name == "" then return end
    M.scaffold(name)
    M.active = name
    vim.cmd("redrawstatus!")
    vim.notify("[plan] Active: " .. name, vim.log.levels.INFO)
    M.open_ard()
end

function M.deactivate()
    M.active = nil
    vim.cmd("redrawstatus!")
    vim.notify("[plan] No active plan", vim.log.levels.INFO)
end

-- ─── Buffer helpers ───────────────────────────────────────────────────────────

-- Return the buffer number for a path if it's already loaded, else nil.
local function loaded_buf(path)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
            and vim.api.nvim_buf_get_name(buf) == path then
            return buf
        end
    end
end

-- Return the window that is showing buf, or nil.
local function win_for_buf(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then return win end
    end
end

-- ─── Open ARD ─────────────────────────────────────────────────────────────────

function M.open_ard(name)
    name = name or M.active
    if not name then
        vim.notify("[plan] No active plan", vim.log.levels.WARN); return
    end
    local path  = M.ard_path(name)
    local buf   = loaded_buf(path)
    local win   = buf and win_for_buf(buf)
    if win then
        vim.api.nvim_set_current_win(win)
    else
        vim.cmd("botright vsplit " .. vim.fn.fnameescape(path))
    end
end

-- ─── Append reference ─────────────────────────────────────────────────────────

-- Append a file reference to the ## References section of the active ARD.
-- Returns the 0-indexed line number of the new entry (for cursor jump).
function M.append_reference(filepath)
    if not M.active then return nil end

    local path    = M.ard_path()
    local rel     = vim.fn.fnamemodify(filepath, ":.")
    local entry   = "### @" .. rel

    -- Work through the buffer API if the file is already loaded.
    local buf = loaded_buf(path)
    if buf then
        local lines    = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local ref_line = nil
        for i, l in ipairs(lines) do
            if l:match("^## References") then ref_line = i - 1; break end -- 0-indexed
        end

        local insert_at
        if ref_line then
            -- Find the last reference entry (starting with ###) after the heading
            local last_ref = ref_line + 1
            while last_ref < #lines and lines[last_ref + 1] == "" do last_ref = last_ref + 1 end
            while last_ref < #lines and lines[last_ref + 1]:match("^###") do last_ref = last_ref + 1 end
            insert_at = last_ref + 1
            vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { entry, "" })
        else
            -- No References section — add one at the end
            insert_at = #lines
            vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { "", "## References", "", entry, "" })
            insert_at = insert_at + 3 -- line of the entry itself (0-indexed)
        end

        vim.api.nvim_buf_call(buf, function() vim.cmd("silent write") end)
        return insert_at
    end

    -- Buffer not loaded — use file IO.
    local lines = {}
    local f = io.open(path, "r")
    if f then
        for l in f:lines() do table.insert(lines, l) end
        f:close()
    end

    local ref_line = nil
    for i, l in ipairs(lines) do
        if l:match("^## References") then ref_line = i; break end -- 1-indexed
    end

    local entry_line_1indexed
    if ref_line then
        -- Find the last reference entry (starting with ###) after the heading
        local insert_at = ref_line + 1
        while insert_at <= #lines and lines[insert_at] == "" do insert_at = insert_at + 1 end
        while insert_at <= #lines and lines[insert_at]:match("^###") do insert_at = insert_at + 1 end
        table.insert(lines, insert_at, "")
        table.insert(lines, insert_at, entry)
        entry_line_1indexed = insert_at
    else
        table.insert(lines, "")
        table.insert(lines, "## References")
        table.insert(lines, "")
        table.insert(lines, entry)
        table.insert(lines, "")
        entry_line_1indexed = #lines - 1
    end

    local fw = io.open(path, "w")
    if fw then fw:write(table.concat(lines, "\n") .. "\n"); fw:close() end

    return entry_line_1indexed - 1 -- return 0-indexed
end

-- ─── Open ARD at reference line ───────────────────────────────────────────────

function M.open_at_reference(filepath)
    if not M.active then return end

    local entry_row_0 = M.append_reference(filepath)
    local path        = M.ard_path()

    -- If already in a window, focus it; otherwise vsplit.
    local buf = loaded_buf(path)
    local win = buf and win_for_buf(buf)
    if win then
        vim.api.nvim_set_current_win(win)
        -- Reload if we wrote via file IO (buf was not loaded when we appended)
        if not buf then vim.cmd("edit") end
    else
        vim.cmd("botright vsplit " .. vim.fn.fnameescape(path))
        vim.cmd("edit") -- pick up file IO changes if any
    end

    -- Jump to the line after the entry heading so the user can type context
    if entry_row_0 then
        local target = entry_row_0 + 2 -- skip the entry heading + blank line
        local line_count = vim.api.nvim_buf_line_count(0)
        if target > line_count then target = line_count end
        vim.api.nvim_win_set_cursor(0, { target, 0 })
    end

    vim.cmd("startinsert")
end

-- ─── <leader>ai handler ───────────────────────────────────────────────────────

-- With an active plan: append current file reference to ARD and open it there.
-- Without an active plan: fall back to the existing ai queue behaviour.
function M.handle_leader_ai()
    if not M.active then
        local ok, ai = pcall(require, "ai")
        if ok then ai.open_add_buffer() end
        return
    end

    local filepath = vim.fn.expand("%:p")
    if filepath == "" then
        M.open_ard(); return
    end

    M.open_at_reference(filepath)
end

-- ─── Lualine component ────────────────────────────────────────────────────────

function M.lualine()
    if not M.active then return "" end
    return "  " .. M.active
end

-- ─── Telescope picker ─────────────────────────────────────────────────────────

function M.pick()
    local ok, pickers = pcall(require, "telescope.pickers")
    if not ok then
        -- Fallback: vim.ui.select
        local plans   = M.list_plans()
        local entries = {}
        for _, p in ipairs(plans) do table.insert(entries, p) end
        table.insert(entries, "[+ new plan]")
        vim.ui.select(entries, { prompt = "Plans" }, function(choice)
            if not choice then return end
            if choice == "[+ new plan]" then
                vim.ui.input({ prompt = "Plan name: " }, function(name)
                    if name and name ~= "" then M.activate(name) end
                end)
            else
                M.activate(choice)
            end
        end)
        return
    end

    local finders     = require("telescope.finders")
    local conf        = require("telescope.config").values
    local actions     = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title  = "Plans  (type a new name to create)",
        finder        = finders.new_table({ results = M.list_plans() }),
        sorter        = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                local input     = action_state.get_current_line()
                actions.close(prompt_bufnr)
                local name = (selection and selection[1]) or input
                if name and name ~= "" then M.activate(name) end
            end)
            return true
        end,
    }):find()
end

return M
