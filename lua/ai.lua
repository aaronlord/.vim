local M             = {}

local uv            = vim.uv or vim.loop

-- ─── State ────────────────────────────────────────────────────────────────────

local TASKS_DIR     = vim.fn.expand("~/.pi/nvim-tasks")
local DONE_DIR      = vim.fn.expand("~/.pi/nvim-done")
local ATTENTION_DIR = vim.fn.expand("~/.pi/nvim-attention")
vim.fn.mkdir(TASKS_DIR, "p")
vim.fn.mkdir(DONE_DIR, "p")
vim.fn.mkdir(ATTENTION_DIR, "p")

M.tmux_target        = 2
-- queue prompts always go to pane M.tmux_target; visual tasks always open a new window
M.model              = "claude-sonnet-4.6" -- set via :AIModel or <C-m> in a task pane
M._task_counter      = 0  -- kept for backwards compat; window names now use random IDs
M.visual_tasks       = {}
M.queue              = {}
M.last_prompt        = nil

M.agents             = {
    copilot = { cmd = "gh copilot", process_pattern = "gh copilot" },
    claude  = { cmd = "claude", process_pattern = "claude" },
    pi      = { cmd = "pi", process_pattern = "pi" },
}

local function random_id(len)
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local t = {}
    for _ = 1, len or 6 do
        local i = math.random(1, #chars)
        t[#t + 1] = chars:sub(i, i)
    end
    return table.concat(t)
end

local ok, local_cfg  = pcall(require, "local")
M.agent              = (ok and local_cfg.agent and M.agents[local_cfg.agent]) or M.agents.copilot

-- ─── Highlights & spinner ─────────────────────────────────────────────────────

local tracking_nsid  = vim.api.nvim_create_namespace("ai.visual_track")
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

vim.api.nvim_set_hl(0, "AiTaskWorking", { fg = "#61afef", bg = "#1d2b3a", default = true })
vim.api.nvim_set_hl(0, "AiTaskAttention", { fg = "#e5c07b", bg = "#3a2e0a", default = true })
vim.api.nvim_set_hl(0, "AiTaskReady", { fg = "#98c379", bg = "#1d3a27", default = true })

-- ─── Queue ────────────────────────────────────────────────────────────────────

function M.queue_add(content) table.insert(M.queue, content) end

function M.queue_clear() M.queue = {} end

function M.queue_count() return #M.queue end

-- ─── tmux helpers ─────────────────────────────────────────────────────────────

local function tmux_available()
    if vim.fn.executable("tmux") ~= 1 then
        vim.notify("[ai] tmux not found in PATH", vim.log.levels.ERROR); return false
    end
    if not os.getenv("TMUX") then
        vim.notify("[ai] Not inside a tmux session", vim.log.levels.ERROR); return false
    end
    return true
end

-- Write content to a temp file, load into a tmux buffer, paste via bracketed-paste.
-- Pass focus=true to also select-window (steal focus) before pasting.
local function tmux_paste(target, content, tag, focus)
    if not tmux_available() or not content or content == "" then return end
    if focus then
        vim.fn.system(string.format("tmux select-window -t %q", target))
        vim.wait(100)
    end
    local tf = string.format("/tmp/ai_%s_%d", tag or "buf", os.time())
    local f  = io.open(tf, "w")
    if not f then return end
    f:write("\x1b[200~" .. content .. "\x1b[201~"); f:close()
    local bname = "ai_" .. (tag or "buf")
    vim.fn.system(string.format("tmux load-buffer -b %q %q", bname, tf))
    vim.fn.system(string.format("tmux paste-buffer -b %q -t %q", bname, target))
    os.remove(tf)
end

local function is_agent_running(target)
    if not tmux_available() then return false end
    local pid = vim.fn.system(
        string.format("tmux list-panes -t %q -F '#{pane_pid}'", target)):gsub("\n", "")
    if not pid or pid == "" then return false end
    local out = vim.fn.system(string.format("pgrep -P %s -f %s",
        vim.fn.shellescape(pid), vim.fn.shellescape(M.agent.process_pattern)))
    return out ~= "" and out:find("%d+") ~= nil
end

-- Create a named tmux window, start the agent inside it, return the window ID.
-- Pass model to use --model flag on launch (pi only).
local function open_pi_task_pane(window_name, model)
    if not tmux_available() then return nil end
    local window_id = vim.trim(vim.fn.system(
        string.format('tmux new-window -n %q -d -P -F "#{window_id}"', window_name)))
    if window_id == "" then
        vim.notify("[ai] Failed to create tmux window '" .. window_name .. "'", vim.log.levels.ERROR)
        return nil
    end
    local cmd = M.agent.cmd
    if model and M.agent.cmd == "pi" then
        cmd = cmd .. " --model " .. vim.fn.shellescape(model)
    end
    vim.fn.system(string.format("tmux send-keys -t %q %q Enter", window_id, cmd))
    return window_id
end

-- ─── Model ────────────────────────────────────────────────────────────────────

function M.pick_model()
    local raw   = vim.fn.system("pi --list-models 2>/dev/null")
    local names = { "default" }
    for line in raw:gmatch("[^\n]+") do
        local cols = {}
        for col in line:gmatch("%S+") do table.insert(cols, col) end
        if #cols >= 2 and cols[1] ~= "provider" then table.insert(names, cols[2]) end
    end
    vim.ui.select(names, { prompt = "Model:" }, function(choice)
        if not choice then return end
        M.model = (choice ~= "default") and choice or nil
        vim.cmd("redrawstatus!")
    end)
end

-- ─── Dispatch ─────────────────────────────────────────────────────────────────

function M._dispatch_prompt(prompt)
    if is_agent_running(M.tmux_target) then
        tmux_paste(M.tmux_target, prompt, "prompt", true)
        vim.wait(250)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", M.tmux_target))
    else
        tmux_paste(M.tmux_target, M.agent.cmd, "cmd", true)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", M.tmux_target))
        vim.wait(3000)
        tmux_paste(M.tmux_target, prompt, "prompt", true)
        vim.wait(250)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", M.tmux_target))
    end
end

-- ─── Shared buffer utilities ──────────────────────────────────────────────────

local cmp = require("cmp")

local function make_rel(path)
    if not path or path == "" then return nil end
    local rel = vim.fn.fnamemodify(path, ":.")
    return (rel ~= path) and rel or vim.fn.fnamemodify(path, ":p")
end

local function get_diagnostic_text()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    return #diags > 0 and diags[1].message or nil
end

-- Applied to every prompt/add/review buffer: options, spell, cmp, <C-f> file expander.
local function setup_prompt_buffer(buf)
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.cmd("set spell spelllang=en_us")

    cmp.setup.buffer({
        sources = {
            { name = "calc" }, { name = "luasnip" }, { name = "nvim_lsp" },
            { name = "path" }, { name = "buffer" },
        },
    })

    -- <C-f> — find a file by the word under cursor and expand it as @path
    vim.keymap.set("i", "<C-f>", function()
        local line   = vim.api.nvim_get_current_line()
        local col    = vim.api.nvim_win_get_cursor(0)[2]
        local ws, we = col, col
        while we < #line and line:sub(we + 1, we + 1):match("[a-zA-Z0-9_]") do we = we + 1 end
        while ws > 0 and line:sub(ws, ws):match("[a-zA-Z0-9_]") do ws = ws - 1 end
        local word = line:sub(ws + 1, we)
        if word == "" then return end

        local cwd    = vim.fn.getcwd()
        local search = word:lower()
        local found  = nil

        local function scan(dir)
            local handle = vim.loop.fs_scandir(dir)
            if not handle then return end
            while true do
                local name, typ = vim.loop.fs_scandir_next(handle)
                if not name then break end
                if typ == "directory" and
                    (name == "node_modules" or name == ".git" or
                        name == ".env" or name:sub(1, 1) == ".") then
                    goto continue
                end
                if typ == "file" and name:lower():find(search, 1, true) then
                    found = dir .. "/" .. name; return
                elseif typ == "directory" and not found then
                    scan(dir .. "/" .. name)
                end
                ::continue::
            end
        end

        scan(cwd)
        if found then
            local rel = found:sub(#cwd + 2)
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            vim.api.nvim_buf_set_text(0, row, ws, row, we, { "@" .. rel })
        end
    end, { buffer = buf, noremap = true, desc = "Expand filename to @path" })
end

-- ─── Add-to-queue buffer  (<leader>ai in normal mode) ─────────────────────────

function M.open_add_buffer(opts)
    opts          = opts or {}
    local diag    = get_diagnostic_text()
    local curfile = make_rel(vim.fn.expand("%:p"))

    if not opts.start_line and diag then
        opts.start_line = vim.fn.line(".")
        opts.end_line   = vim.fn.line(".")
    end

    local lines = {}

    if curfile then
        local heading = "### @" .. curfile
        if opts.start_line and opts.end_line then
            heading = heading .. (opts.start_line == opts.end_line
                and " (line " .. opts.start_line .. ")"
                or " (lines " .. opts.start_line .. "-" .. opts.end_line .. ")")
        end
        table.insert(lines, heading)
    end
    table.insert(lines, "")
    table.insert(lines, "")

    if diag then
        table.insert(lines, "I have a diagnostic error that I would like you to help me with:")
        table.insert(lines, "")
        for l in diag:gmatch("[^\n]+") do table.insert(lines, "> " .. l) end
        table.insert(lines, "")
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)
    setup_prompt_buffer(buf)

    vim.keymap.set("n", "cc", function()
        local content = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
        if content == "" then
            vim.notify("[ai] Prompt is empty", vim.log.levels.WARN); return
        end
        M.queue_add(content)
        local n = M.queue_count()
        vim.cmd("bdelete!")
        vim.notify(string.format("[ai] Added to queue (%d item%s)", n, n == 1 and "" or "s"), vim.log.levels.INFO)
    end, { buffer = buf, noremap = true, desc = "Add to AI queue" })

    vim.keymap.set("n", "q", function()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Cancel" })

    vim.cmd("normal! gg")
    vim.cmd("normal! 2j")
    vim.cmd("startinsert")
end

-- ─── Review-queue buffer  (<leader><leader>ai) ────────────────────────────────

function M.open_review_buffer()
    if M.queue_count() == 0 then
        vim.notify("[ai] Queue is empty — use <leader>ai to add items first", vim.log.levels.INFO)
        return
    end

    local buf   = vim.api.nvim_create_buf(false, true)
    local lines = { "", "---", "" }

    for _, item in ipairs(M.queue) do
        for _, l in ipairs(vim.split(item, "\n", { plain = true })) do
            table.insert(lines, l)
        end
        table.insert(lines, ""); table.insert(lines, "---"); table.insert(lines, "")
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)
    setup_prompt_buffer(buf)

    local function update_winbar()
        local label = M.model and ("[" .. M.model .. "]") or "[default]"
        local n     = M.queue_count()
        vim.api.nvim_set_option_value("winbar",
            string.format(" %s  %d item%s   cc send  <leader>air restore  q cancel ",
                label, n, n == 1 and "" or "s"), { win = 0 })
    end
    update_winbar()

    vim.keymap.set("n", "cc", function()
        local prompt = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
        if prompt == "" then
            vim.notify("[ai] Prompt is empty", vim.log.levels.WARN); return
        end
        M._dispatch_prompt(prompt)
        M.last_prompt = prompt
        M.queue_clear()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Send queue to AI agent" })

    vim.keymap.set("n", "q", function()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Close without sending" })

    -- Restore last prompt into this buffer (review-buffer-only binding)
    vim.keymap.set("n", "<leader>air", function()
        if not M.last_prompt or M.last_prompt == "" then
            vim.notify("[ai] No previous prompt to restore", vim.log.levels.WARN); return
        end
        local restored = vim.split(M.last_prompt, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, restored)
        vim.notify("[ai] Last prompt restored", vim.log.levels.INFO)
    end, { buffer = buf, noremap = true, desc = "Restore last sent prompt" })

    vim.cmd("normal! gg")
end

-- ─── Visual task tracking ─────────────────────────────────────────────────────

local function task_file(id) return TASKS_DIR .. "/" .. id .. ".json" end
local function done_file(id) return DONE_DIR .. "/" .. id .. ".json" end
local function attention_file(id) return ATTENTION_DIR .. "/" .. id .. ".json" end
local function temp_file(id) return "/tmp/pi-nvim-" .. id .. ".block" end

local function new_task_id()
    return string.format("%d_%d", os.time(), math.random(10000, 99999))
end

local function clear_task_marks(task)
    if task.spinner_timer and not task.spinner_timer:is_closing() then
        task.spinner_timer:stop(); task.spinner_timer:close(); task.spinner_timer = nil
    end
    if task.timer and not task.timer:is_closing() then
        task.timer:stop(); task.timer:close()
    end
    if vim.api.nvim_buf_is_valid(task.buffer) then
        vim.api.nvim_buf_clear_namespace(task.buffer, tracking_nsid, 0, -1)
    end
end

local function remove_task(id)
    for i, t in ipairs(M.visual_tasks) do
        if t.id == id then
            table.remove(M.visual_tasks, i); return
        end
    end
end

local function cleanup_task(task)
    if task.window_id and task.window_id ~= "" then
        vim.fn.system(string.format("tmux kill-window -t %q", task.window_id))
    end
    clear_task_marks(task)
    remove_task(task.id)
    os.remove(task_file(task.id))
    os.remove(done_file(task.id))
    os.remove(temp_file(task.id))
end

local function task_at_cursor()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, t in ipairs(M.visual_tasks) do
        if t.state == "ready" and t.buffer == cur_buf
            and cur_row >= t.review_start_row and cur_row <= t.review_end_row then
            return t
        end
    end
end

-- Like task_at_cursor but works for any state (working / attention / ready).
-- Falls back to extmark positions for live tasks.
local function any_task_at_cursor()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, t in ipairs(M.visual_tasks) do
        if t.buffer ~= cur_buf then goto continue end
        if t.state == "ready" then
            if cur_row >= t.review_start_row and cur_row <= t.review_end_row then
                return t
            end
        else
            local s = vim.api.nvim_buf_get_extmark_by_id(t.buffer, tracking_nsid, t.start_mark, {})
            local e = vim.api.nvim_buf_get_extmark_by_id(t.buffer, tracking_nsid, t.end_mark, {})
            if s and #s > 0 then
                local sr = s[1]
                local er = (#e > 0) and e[1] or s[1]
                if cur_row >= sr and cur_row <= er then return t end
            end
        end
        ::continue::
    end
end

-- ─── Visual task diff review ──────────────────────────────────────────────────

local function show_task_review(task)
    local orig_lines = task.original_lines
    local pi_lines   = vim.api.nvim_buf_get_lines(
        task.buffer, task.review_start_row, task.review_end_row + 1, false)
    local ft         = vim.api.nvim_get_option_value("filetype", { buf = task.buffer })

    local orig_buf   = vim.api.nvim_create_buf(false, true)
    local new_buf    = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(orig_buf, 0, -1, false, orig_lines)
    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, pi_lines)
    for _, b in ipairs({ orig_buf, new_buf }) do
        vim.api.nvim_set_option_value("filetype", ft, { buf = b })
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = b })
        vim.api.nvim_set_option_value("modifiable", true, { buf = b })
    end

    vim.cmd("tabnew")
    local orig_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(orig_win, orig_buf)
    vim.cmd("diffthis | vsplit")
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(new_win, new_buf)
    vim.cmd("diffthis")

    vim.api.nvim_set_option_value("winbar", " original ", { win = orig_win })
    vim.api.nvim_set_option_value("winbar",
        " ✨ pi output   [<leader>a] accept  [<leader>r] reject ", { win = new_win })

    local function close_review() vim.cmd("diffoff! | tabclose") end

    local function accept()
        close_review(); cleanup_task(task)
        vim.notify("[ai] Pi changes accepted ✓", vim.log.levels.INFO)
    end

    local function reject()
        close_review()
        vim.api.nvim_buf_set_lines(
            task.buffer, task.review_start_row, task.review_end_row + 1, false, task.original_lines)
        cleanup_task(task)
        vim.notify("[ai] Pi changes rejected", vim.log.levels.INFO)
    end

    for _, b in ipairs({ orig_buf, new_buf }) do
        vim.keymap.set("n", "<leader>a", accept,
            { buffer = b, noremap = true, nowait = true, desc = "Accept Pi changes" })
        vim.keymap.set("n", "<leader>r", reject,
            { buffer = b, noremap = true, nowait = true, desc = "Reject Pi changes" })
    end
end

-- ─── Visual task lifecycle ────────────────────────────────────────────────────

function M.on_task_done(task)
    if not vim.api.nvim_buf_is_valid(task.buffer) then
        vim.notify("[ai] task done but buffer is gone", vim.log.levels.WARN)
        cleanup_task(task); return
    end

    -- Use mtime to detect if the agent actually wrote to the temp file.
    -- An empty write is valid — it means the agent wants to delete the selection.
    local tf      = temp_file(task.id)
    local tf_stat = vim.uv.fs_stat(tf)
    if not tf_stat then
        vim.notify("[ai] task done but temp file missing: " .. tf, vim.log.levels.WARN)
        cleanup_task(task); return
    end
    if tf_stat.mtime.sec <= (task.temp_init_mtime or 0) then
        vim.notify("[ai] task done but Pi wrote nothing to the temp file", vim.log.levels.WARN)
        cleanup_task(task); return
    end

    local f = io.open(tf, "r")
    if not f then
        vim.notify("[ai] task done but temp file unreadable: " .. tf, vim.log.levels.WARN)
        cleanup_task(task); return
    end
    local replacement = f:read("*a"); f:close()

    -- Mode B sentinel: agent edited files directly.
    -- Instead of reloading the whole buffer (which would discard the user's
    -- unsaved edits), read the disk file, extract the agent's replacement for
    -- the selection region, and apply it at the current extmark positions.
    if vim.trim(replacement) == "__DIRECT_EDIT__" then
        local fname = vim.api.nvim_buf_get_name(task.buffer)
        local fh    = io.open(fname, "r")
        if not fh then
            -- Fallback: full reload (old behaviour)
            cleanup_task(task)
            vim.api.nvim_buf_call(task.buffer, function() vim.cmd("edit") end)
            vim.notify("[ai] " .. (task.window_name or task.id) .. " done (direct edit) ✓", vim.log.levels.INFO)
            return
        end
        local disk_content = fh:read("*a"); fh:close()
        local disk_lines   = vim.split(disk_content, "\n", { plain = true })
        if disk_lines[#disk_lines] == "" then table.remove(disk_lines) end

        -- Re-read extmarks — user may have added/removed lines while agent worked.
        local sd = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
        local ed = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.end_mark, {})
        if not sd or #sd == 0 then
            cleanup_task(task)
            vim.notify("[ai] task done but selection marks are gone", vim.log.levels.WARN)
            return
        end
        local start_row = sd[1]
        local end_row   = (#ed > 0) and ed[1] or sd[1]

        -- Extract the agent's replacement lines from the disk file.
        -- Assumes the agent only changed content within the original selection;
        -- lines before orig_start_row and after orig_end_row are untouched.
        local prefix_count = task.orig_start_row or start_row
        local orig_total   = task.orig_file_line_count
            or vim.api.nvim_buf_line_count(task.buffer)
        local orig_end     = task.orig_end_row or end_row
        local suffix_count = orig_total - orig_end - 1
        local agent_start  = prefix_count          -- 0-indexed into disk_lines
        local agent_end    = #disk_lines - suffix_count - 1  -- 0-indexed, inclusive
        local lines        = {}
        for i = agent_start + 1, agent_end + 1 do  -- convert to 1-indexed
            table.insert(lines, disk_lines[i])
        end
        if lines[#lines] == "" then table.remove(lines) end

        if #lines == 0 then
            vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, {})
            cleanup_task(task)
            vim.notify("[ai] " .. (task.window_name or task.id) .. " done (direct edit, deleted) ✓", vim.log.levels.INFO)
            return
        end

        task.original_lines = vim.api.nvim_buf_get_lines(task.buffer, start_row, end_row + 1, false)
        vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, lines)
        local new_end = start_row + #lines - 1

        if task.spinner_timer and not task.spinner_timer:is_closing() then
            task.spinner_timer:stop(); task.spinner_timer:close(); task.spinner_timer = nil
        end

        vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, new_end, 0, { id = task.end_mark })
        for _, hm in ipairs(task.highlight_marks or {}) do
            pcall(vim.api.nvim_buf_del_extmark, task.buffer, tracking_nsid, hm)
        end
        task.highlight_marks = {}
        for row = start_row, new_end do
            table.insert(task.highlight_marks,
                vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, row, 0,
                    { line_hl_group = "AiTaskReady" }))
        end

        task.state            = "ready"
        task.review_start_row = start_row
        task.review_end_row   = new_end

        local sd2 = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
        if sd2 and #sd2 > 0 then
            vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, sd2[1], sd2[2], {
                id            = task.start_mark,
                right_gravity = false,
                virt_text     = { { (task.window_name or task.id), "AiTaskReady" } },
                virt_text_pos = "right_align",
            })
        end

        vim.notify("[ai] " .. (task.window_name or task.id) .. " done ✓", vim.log.levels.INFO)
        return
    end
    local s = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
    local e = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.end_mark, {})
    if not s or #s == 0 then
        vim.notify("[ai] task done but selection marks are gone", vim.log.levels.WARN)
        cleanup_task(task); return
    end

    local start_row = s[1]
    local end_row   = (#e > 0) and e[1] or s[1]
    local lines     = vim.split(replacement, "\n", { plain = true })
    if lines[#lines] == "" then table.remove(lines) end

    -- Empty lines = intentional deletion — apply immediately with no review phase
    if #lines == 0 then
        vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, {})
        cleanup_task(task)
        vim.notify("[ai] " .. (task.window_name or task.id) .. " done (selection deleted) ✓", vim.log.levels.INFO)
        return
    end

    task.original_lines = vim.api.nvim_buf_get_lines(task.buffer, start_row, end_row + 1, false)
    vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, lines)
    local new_end = start_row + #lines - 1

    if task.spinner_timer and not task.spinner_timer:is_closing() then
        task.spinner_timer:stop(); task.spinner_timer:close(); task.spinner_timer = nil
    end

    vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, new_end, 0, { id = task.end_mark })

    for _, hm in ipairs(task.highlight_marks or {}) do
        pcall(vim.api.nvim_buf_del_extmark, task.buffer, tracking_nsid, hm)
    end
    task.highlight_marks = {}
    for row = start_row, new_end do
        table.insert(task.highlight_marks,
            vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, row, 0,
                { line_hl_group = "AiTaskReady" }))
    end

    task.state            = "ready"
    task.review_start_row = start_row
    task.review_end_row   = new_end

    local s2              = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
    if s2 and #s2 > 0 then
        vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, s2[1], s2[2], {
            id            = task.start_mark,
            right_gravity = false,
            virt_text     = { { (task.window_name or task.id), "AiTaskReady" } },
            virt_text_pos = "right_align",
        })
    end

    vim.notify("[ai] " .. (task.window_name or task.id) .. " done ✓", vim.log.levels.INFO)
end

function M.on_task_attention(task)
    if task.state ~= "working" then return end
    if not vim.api.nvim_buf_is_valid(task.buffer) then return end

    -- Stop spinner
    if task.spinner_timer and not task.spinner_timer:is_closing() then
        task.spinner_timer:stop(); task.spinner_timer:close(); task.spinner_timer = nil
    end

    local s = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
    local e = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.end_mark, {})
    if not s or #s == 0 then return end
    local start_row = s[1]
    local end_row   = (#e > 0) and e[1] or s[1]

    -- Swap highlights to yellow
    for _, hm in ipairs(task.highlight_marks or {}) do
        pcall(vim.api.nvim_buf_del_extmark, task.buffer, tracking_nsid, hm)
    end
    task.highlight_marks = {}
    for row = start_row, end_row do
        table.insert(task.highlight_marks,
            vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, row, 0,
                { line_hl_group = "AiTaskAttention" }))
    end

    -- Replace spinner virt_text with attention indicator
    vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, start_row, 0, {
        id            = task.start_mark,
        right_gravity = false,
        virt_text     = { { "⚠ " .. (task.window_name or task.id), "AiTaskAttention" } },
        virt_text_pos = "right_align",
    })

    task.state = "attention"
end

local function start_done_watcher(task)
    local df    = done_file(task.id)
    local af    = attention_file(task.id)
    local timer = uv.new_timer()
    task.timer  = timer
    timer:start(500, 500, vim.schedule_wrap(function()
        -- Check for attention signal
        if task.state == "working" then
            local fa = io.open(af, "r")
            if fa then
                fa:close(); M.on_task_attention(task)
            end
        end
        -- Check for completion
        local f = io.open(df, "r")
        if not f then return end
        local content = f:read("*a"); f:close()
        if content and content ~= "" then
            timer:stop(); timer:close(); task.timer = nil
            M.on_task_done(task)
        end
    end))
end

-- Auto-accept pending tasks when the buffer is written
vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function(ev)
        for _, t in ipairs(M.visual_tasks) do
            if t.state == "ready" and t.buffer == ev.buf then cleanup_task(t) end
        end
    end,
})

-- ─── Cursor-based accept / reject / review ────────────────────────────────────

function M.jump_to_task_pane()
    local t = any_task_at_cursor()
    local target = (t and t.window_id and t.window_id ~= "") and t.window_id or M.tmux_target
    if not tmux_available() then return end
    vim.fn.system(string.format("tmux select-window -t %q", target))
end

function M.review_visual_task()
    local t = task_at_cursor()
    if t then
        show_task_review(t)
    else
        vim.notify("[ai] No task ready for review at cursor", vim.log.levels.INFO)
    end
end

function M.accept_visual_task()
    local t = task_at_cursor()
    if not t then
        vim.notify("[ai] No task ready for review at cursor", vim.log.levels.INFO); return
    end
    cleanup_task(t)
    vim.notify("[ai] Pi changes accepted ✓", vim.log.levels.INFO)
end

function M.reject_visual_task()
    local t = task_at_cursor()
    if not t then
        vim.notify("[ai] No task ready for review at cursor", vim.log.levels.INFO); return
    end
    vim.api.nvim_buf_set_lines(t.buffer, t.review_start_row, t.review_end_row + 1, false, t.original_lines)
    cleanup_task(t)
    vim.notify("[ai] Pi changes rejected", vim.log.levels.INFO)
end

function M.clear_all_visual_tasks()
    for _, task in ipairs(M.visual_tasks) do clear_task_marks(task) end
    M.visual_tasks = {}
    vim.notify("[ai] All visual tasks cleared", vim.log.levels.INFO)
end

-- ─── Visual task buffer  (<leader>ai in visual mode) ─────────────────────────
-- Always sends to a fresh Pi window.

function M.open_visual_task_buffer()
    local source_buf = vim.api.nvim_get_current_buf()

    local v_pos      = vim.fn.getpos("v")
    local cur_pos    = vim.fn.getpos(".")
    local start_line = v_pos[2]
    local end_line   = cur_pos[2]
    if start_line > end_line then start_line, end_line = end_line, start_line end
    local start_row = start_line - 1
    local end_row   = end_line - 1

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

    local start_mark = vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, start_row, 0,
        { right_gravity = false })
    local end_mark   = vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, end_row, 0, {})

    local id         = new_task_id()
    local task       = {
        id              = id,
        state           = "working",
        buffer          = source_buf,
        start_mark      = start_mark,
        end_mark        = end_mark,
        highlight_marks = {},
        timer           = nil,
        spinner_timer   = nil,
        spinner_frame   = 1,
    }

    local prompt_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { "" })
    vim.cmd("botright vsplit")
    local prompt_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(prompt_win, prompt_buf)
    setup_prompt_buffer(prompt_buf)

    local sent = false

    vim.keymap.set("n", "cc", function()
        local user_prompt = vim.trim(
            table.concat(vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false), "\n"))
        if user_prompt == "" then
            vim.notify("[ai] Prompt is empty", vim.log.levels.WARN); return
        end

        local s = vim.api.nvim_buf_get_extmark_by_id(source_buf, tracking_nsid, start_mark, {})
        local e = vim.api.nvim_buf_get_extmark_by_id(source_buf, tracking_nsid, end_mark, {})
        if not s or #s == 0 then
            vim.notify("[ai] Selection marks lost — was the buffer wiped?", vim.log.levels.ERROR); return
        end

        local cur_start    = s[1]
        local cur_end      = (#e > 0) and e[1] or s[1]

        -- Store original positions so on_task_done can extract the agent's
        -- replacement from the disk file without reloading the whole buffer.
        task.orig_start_row       = cur_start
        task.orig_end_row         = cur_end
        task.orig_file_line_count = vim.api.nvim_buf_line_count(source_buf)

        local code         = table.concat(
            vim.api.nvim_buf_get_lines(source_buf, cur_start, cur_end + 1, false), "\n")

        local ctx_start    = math.max(0, cur_start - 50)
        local ctx_end      = math.min(vim.api.nvim_buf_line_count(source_buf), cur_end + 51)
        local surrounding  = table.concat(
            vim.api.nvim_buf_get_lines(source_buf, ctx_start, ctx_end, false), "\n")

        local task_data    = {
            id              = id,
            file            = vim.api.nvim_buf_get_name(source_buf),
            startLine       = cur_start + 1,
            endLine         = cur_end + 1,
            code            = code,
            surroundingCode = surrounding,
            tempFile        = temp_file(id),
            userPrompt      = user_prompt,
            model           = M.model,
        }

        local ok2, encoded = pcall(vim.fn.json_encode, task_data)
        if not ok2 then
            vim.notify("[ai] Failed to encode task: " .. tostring(encoded), vim.log.levels.ERROR); return
        end
        local jf = io.open(task_file(id), "w")
        if not jf then
            vim.notify("[ai] Failed to write task file", vim.log.levels.ERROR); return
        end
        jf:write(encoded); jf:close()

        local ef = io.open(temp_file(id), "w")
        if ef then
            ef:write(""); ef:close()
        end
        -- Record mtime now so on_task_done can tell if the agent actually wrote to it
        local _tf_stat       = vim.uv.fs_stat(temp_file(id))
        task.temp_init_mtime = _tf_stat and _tf_stat.mtime.sec or 0

        M._task_counter      = M._task_counter + 1
        local window_name    = "pi-" .. random_id()

        vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, cur_start, 0, {
            id            = start_mark,
            right_gravity = false,
            virt_text     = { { spinner_frames[1] .. " " .. window_name, "AiTaskWorking" } },
            virt_text_pos = "right_align",
        })
        for row = cur_start, cur_end do
            table.insert(task.highlight_marks,
                vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, row, 0,
                    { line_hl_group = "AiTaskWorking" }))
        end

        local window_id = open_pi_task_pane(window_name, task_data.model)
        if not window_id then return end

        task.window_id     = window_id
        task.window_name   = window_name

        local spin         = uv.new_timer()
        task.spinner_timer = spin
        spin:start(100, 100, vim.schedule_wrap(function()
            if not vim.api.nvim_buf_is_valid(source_buf) then
                spin:stop(); return
            end
            task.spinner_frame = (task.spinner_frame % #spinner_frames) + 1
            local sv = vim.api.nvim_buf_get_extmark_by_id(source_buf, tracking_nsid, start_mark, {})
            if sv and #sv > 0 then
                vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, sv[1], sv[2], {
                    id            = start_mark,
                    right_gravity = false,
                    virt_text     = { { spinner_frames[task.spinner_frame] .. " " .. window_name, "AiTaskWorking" } },
                    virt_text_pos = "right_align",
                })
            end
        end))

        sent = true
        table.insert(M.visual_tasks, task)
        start_done_watcher(task)
        vim.cmd("bdelete!")
        vim.notify("[ai] " .. window_name .. (M.model and (" [" .. M.model .. "]") or ""), vim.log.levels.INFO)

        vim.defer_fn(function()
            tmux_paste(window_id, "/nvim-task " .. id, "cmd")
            vim.fn.system(string.format("tmux send-keys -t %q Enter", window_id))
        end, 3000)
    end, { buffer = prompt_buf, noremap = true, desc = "Send visual task to Pi" })

    vim.keymap.set("n", "q", function()
        vim.cmd("bdelete!")
    end, { buffer = prompt_buf, noremap = true, desc = "Cancel visual task" })

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer   = prompt_buf,
        once     = true,
        callback = function()
            if not sent then
                vim.api.nvim_buf_clear_namespace(source_buf, tracking_nsid, 0, -1)
            end
        end,
    })

    vim.cmd("startinsert")
end

return M
