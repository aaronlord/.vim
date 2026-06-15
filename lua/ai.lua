local M = {}

local uv = vim.uv or vim.loop

-- ─── Visual task tracking ──────────────────────────────────────────────────

local tracking_nsid = vim.api.nvim_create_namespace("ai.visual_track")
local TASKS_DIR = vim.fn.expand("~/.pi/nvim-tasks")
local DONE_DIR = vim.fn.expand("~/.pi/nvim-done")
vim.fn.mkdir(TASKS_DIR, "p")
vim.fn.mkdir(DONE_DIR, "p")

vim.api.nvim_set_hl(0, "AiTaskWorking", { fg = "#61afef", bg = "#1d2b3a", default = true })
vim.api.nvim_set_hl(0, "AiTaskReady",   { fg = "#98c379", bg = "#1d3a27", default = true })

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

M.visual_tasks = {}

-- forward declarations for tmux helpers defined later in this file
local send_to_existing_session
local send_keys_no_focus  -- like send_to_tmux but without stealing focus
local open_pi_task_pane

M._task_counter = 0

local function new_task_id()
    return string.format("%d_%d", os.time(), math.random(10000, 99999))
end

local function task_file(id)  return TASKS_DIR .. "/" .. id .. ".json" end
local function done_file(id)  return DONE_DIR  .. "/" .. id .. ".json" end
local function temp_file(id)  return "/tmp/pi-nvim-" .. id .. ".block"  end

local function clear_task_marks(task)
    if task.spinner_timer and not task.spinner_timer:is_closing() then
        task.spinner_timer:stop()
        task.spinner_timer:close()
        task.spinner_timer = nil
    end
    if vim.api.nvim_buf_is_valid(task.buffer) then
        vim.api.nvim_buf_clear_namespace(task.buffer, tracking_nsid, 0, -1)
    end
    if task.timer and not task.timer:is_closing() then
        task.timer:stop()
        task.timer:close()
    end
end

local function remove_task(id)
    for i, t in ipairs(M.visual_tasks) do
        if t.id == id then table.remove(M.visual_tasks, i); return end
    end
end

-- Shared cleanup: close Pi pane, clear marks, remove files
local function cleanup_task(task)
    if task.window_id and task.window_id ~= "" then
        vim.fn.system(string.format('tmux kill-window -t %q', task.window_id))
    end
    clear_task_marks(task)
    remove_task(task.id)
    os.remove(task_file(task.id))
    os.remove(done_file(task.id))
    os.remove(temp_file(task.id))
end

-- Open a diff tab for a task that is ready for review.
-- Left = original code (before Pi). Right = Pi's output (already in the buffer).
-- Accept = keep what's in the buffer. Reject = restore original.
local function show_task_review(task)
    local start_row     = task.review_start_row
    local end_row       = task.review_end_row
    local original_lines = task.original_lines
    -- Read live from the buffer in case the user already edited Pi's output
    local pi_lines      = vim.api.nvim_buf_get_lines(task.buffer, start_row, end_row + 1, false)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = task.buffer })

    local orig_buf = vim.api.nvim_create_buf(false, true)
    local new_buf  = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(orig_buf, 0, -1, false, original_lines)
    vim.api.nvim_buf_set_lines(new_buf,  0, -1, false, pi_lines)
    for _, b in ipairs({ orig_buf, new_buf }) do
        vim.api.nvim_set_option_value("filetype",   ft,       { buf = b })
        vim.api.nvim_set_option_value("buftype",    "nofile", { buf = b })
        vim.api.nvim_set_option_value("modifiable", true,     { buf = b })
    end

    vim.cmd("tabnew")
    local orig_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(orig_win, orig_buf)
    vim.cmd("diffthis")
    vim.cmd("vsplit")
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(new_win, new_buf)
    vim.cmd("diffthis")

    vim.api.nvim_win_set_option(orig_win, "winbar", " original ")
    vim.api.nvim_win_set_option(new_win,  "winbar", " ✨ pi output   [<leader>a] accept  [<leader>r] reject ")

    local function close_review()
        vim.cmd("diffoff!")
        vim.cmd("tabclose")
    end

    local function accept()
        -- Pi's code is already in the buffer; nothing to apply
        close_review()
        cleanup_task(task)
        vim.notify("[ai] Pi changes accepted ✓", vim.log.levels.INFO)
    end

    local function reject()
        -- Restore original code
        close_review()
        vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, original_lines)
        cleanup_task(task)
        vim.notify("[ai] Pi changes rejected", vim.log.levels.INFO)
    end

    for _, b in ipairs({ orig_buf, new_buf }) do
        vim.keymap.set("n", "<leader>a", accept, { buffer = b, noremap = true, nowait = true, desc = "Accept Pi changes" })
        vim.keymap.set("n", "<leader>r", reject, { buffer = b, noremap = true, nowait = true, desc = "Reject Pi changes" })
    end
end

function M.on_task_done(task)
    if not vim.api.nvim_buf_is_valid(task.buffer) then
        vim.notify("[ai] task done but buffer is gone", vim.log.levels.WARN)
        cleanup_task(task)
        return
    end

    local f = io.open(temp_file(task.id), "r")
    if not f then
        vim.notify("[ai] task done but temp file missing: " .. temp_file(task.id), vim.log.levels.WARN)
        cleanup_task(task)
        return
    end
    local replacement = f:read("*a")
    f:close()

    if not replacement or vim.trim(replacement) == "" then
        vim.notify("[ai] task done but Pi wrote nothing to the temp file", vim.log.levels.WARN)
        cleanup_task(task)
        return
    end

    local s = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
    local e = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.end_mark, {})
    if not s or #s == 0 then
        vim.notify("[ai] task done but selection marks are gone", vim.log.levels.WARN)
        cleanup_task(task)
        return
    end

    local start_row = s[1]
    local end_row   = (#e > 0) and e[1] or s[1]

    local lines = vim.split(replacement, "\n", { plain = true })
    if lines[#lines] == "" then table.remove(lines) end

    -- Save original so the user can reject and restore later
    task.original_lines = vim.api.nvim_buf_get_lines(task.buffer, start_row, end_row + 1, false)

    -- Put Pi's code into the buffer so the user can read it in context
    vim.api.nvim_buf_set_lines(task.buffer, start_row, end_row + 1, false, lines)
    local new_end_row = start_row + #lines - 1

    -- Stop spinner
    if task.spinner_timer and not task.spinner_timer:is_closing() then
        task.spinner_timer:stop()
        task.spinner_timer:close()
        task.spinner_timer = nil
    end

    -- Re-anchor end_mark at the new end of Pi's output
    vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, new_end_row, 0, {
        id = task.end_mark,
    })

    -- Refresh line highlights to cover Pi's (possibly different-length) output
    for _, hm_id in ipairs(task.highlight_marks or {}) do
        pcall(vim.api.nvim_buf_del_extmark, task.buffer, tracking_nsid, hm_id)
    end
    task.highlight_marks = {}
    for row = start_row, new_end_row do
        local hm = vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, row, 0, {
            line_hl_group = "AiTaskReady",
        })
        table.insert(task.highlight_marks, hm)
    end

    task.state            = "ready"
    task.review_start_row = start_row
    task.review_end_row   = new_end_row

    -- Flip the indicator
    local s2 = vim.api.nvim_buf_get_extmark_by_id(task.buffer, tracking_nsid, task.start_mark, {})
    if s2 and #s2 > 0 then
        vim.api.nvim_buf_set_extmark(task.buffer, tracking_nsid, s2[1], s2[2], {
            id            = task.start_mark,
            right_gravity = false,
            virt_text     = { { (task.window_name or task.id), "AiTaskReady" } },
            virt_text_pos = "right_align",
        })
    end

    vim.notify("[ai] " .. (task.window_name or task.id) .. " done", vim.log.levels.INFO)
end

local function task_at_cursor()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, t in ipairs(M.visual_tasks) do
        if t.state == "ready" and t.buffer == cur_buf then
            if cur_row >= t.review_start_row and cur_row <= t.review_end_row then
                return t
            end
        end
    end
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
        vim.notify("[ai] No task ready for review at cursor", vim.log.levels.INFO)
        return
    end
    cleanup_task(t)
    vim.notify("[ai] Pi changes accepted ✓", vim.log.levels.INFO)
end

function M.reject_visual_task()
    local t = task_at_cursor()
    if not t then
        vim.notify("[ai] No task ready for review at cursor", vim.log.levels.INFO)
        return
    end
    vim.api.nvim_buf_set_lines(t.buffer, t.review_start_row, t.review_end_row + 1, false, t.original_lines)
    cleanup_task(t)
    vim.notify("[ai] Pi changes rejected", vim.log.levels.INFO)
end

-- Accept all ready tasks for a buffer when it is written
vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function(ev)
        for _, t in ipairs(M.visual_tasks) do
            if t.state == "ready" and t.buffer == ev.buf then
                cleanup_task(t)
            end
        end
    end,
})

local function start_done_watcher(task)
    local df = done_file(task.id)
    local timer = uv.new_timer()
    task.timer = timer
    timer:start(500, 500, vim.schedule_wrap(function()
        local f = io.open(df, "r")
        if not f then return end
        local content = f:read("*a")
        f:close()
        if content and content ~= "" then
            timer:stop()
            timer:close()
            task.timer = nil
            M.on_task_done(task)
        end
    end))
end

function M.clear_all_visual_tasks()
    for _, task in ipairs(M.visual_tasks) do
        clear_task_marks(task)
    end
    M.visual_tasks = {}
    vim.notify("[ai] All visual tasks cleared", vim.log.levels.INFO)
end

function M.open_visual_task_buffer()
    local source_buf = vim.api.nvim_get_current_buf()

    -- Capture selection while still in visual mode
    local v_pos     = vim.fn.getpos("v")
    local cur_pos   = vim.fn.getpos(".")
    local start_line = v_pos[2]
    local end_line   = cur_pos[2]
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    local start_row = start_line - 1  -- 0-indexed
    local end_row   = end_line   - 1

    -- Exit visual mode so extmarks can be placed cleanly
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false
    )

    -- Tracking extmarks only — no highlight or virt_text yet.
    local start_mark = vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, start_row, 0, {
        right_gravity = false,
    })
    local end_mark   = vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, end_row,   0, {})

    local id = new_task_id()
    local task = {
        id              = id,
        buffer          = source_buf,
        start_mark      = start_mark,
        end_mark        = end_mark,
        highlight_marks = {},
        timer           = nil,
        spinner_timer   = nil,
        spinner_frame   = 1,
    }

    -- ── Prompt buffer ───────────────────────────────────────────────────
    local prompt_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { "" })
    vim.cmd("botright vsplit")
    local prompt_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(prompt_win, prompt_buf)
    vim.api.nvim_set_option_value("buftype",  "acwrite",  { buf = prompt_buf })
    vim.api.nvim_set_option_value("modified", false,      { buf = prompt_buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = prompt_buf })
    vim.cmd("set spell spelllang=en_us")
    vim.cmd("startinsert")

    local function update_winbar()
        local label = M.model and ("[" .. M.model .. "]") or "[default]"
        vim.api.nvim_win_set_option(
            prompt_win, "winbar",
            " " .. label .. "  <C-m> change  cc send  q cancel "
        )
    end
    update_winbar()

    vim.keymap.set({ "n", "i" }, "<C-m>", M.pick_model,
        { buffer = prompt_buf, noremap = true, desc = "Change model for this task" })

    local sent = false

    vim.keymap.set("n", "cc", function()
        local user_prompt = vim.trim(
            table.concat(vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false), "\n")
        )
            if user_prompt == "" then
                vim.notify("[ai] Prompt is empty", vim.log.levels.WARN)
                return
            end

            -- Read CURRENT extmark positions — they've tracked the block as you edited
            local s = vim.api.nvim_buf_get_extmark_by_id(source_buf, tracking_nsid, start_mark, {})
            local e = vim.api.nvim_buf_get_extmark_by_id(source_buf, tracking_nsid, end_mark, {})
            if not s or #s == 0 then
                vim.notify("[ai] Selection marks lost — was the buffer wiped?", vim.log.levels.ERROR)
                return
            end

            local cur_start_row  = s[1]
            local cur_end_row    = (#e > 0) and e[1] or s[1]
            local cur_start_line = cur_start_row + 1
            local cur_end_line   = cur_end_row   + 1

            local code_lines = vim.api.nvim_buf_get_lines(source_buf, cur_start_row, cur_end_row + 1, false)
            local code       = table.concat(code_lines, "\n")

            local ctx_start = math.max(0, cur_start_row - 50)
            local ctx_end   = math.min(vim.api.nvim_buf_line_count(source_buf), cur_end_row + 51)
            local ctx_lines = vim.api.nvim_buf_get_lines(source_buf, ctx_start, ctx_end, false)
            local surrounding = table.concat(ctx_lines, "\n")

            local file_path = vim.api.nvim_buf_get_name(source_buf)
            local tf        = temp_file(id)

            local task_data = {
                id              = id,
                file            = file_path,
                startLine       = cur_start_line,
                endLine         = cur_end_line,
                code            = code,
                surroundingCode = surrounding,
                tempFile        = tf,
                userPrompt      = user_prompt,
                model           = M.model,
            }
            local ok, encoded = pcall(vim.fn.json_encode, task_data)
            if not ok then
                vim.notify("[ai] Failed to encode task JSON: " .. tostring(encoded), vim.log.levels.ERROR)
                return
            end
            local jf = io.open(task_file(id), "w")
            if not jf then
                vim.notify("[ai] Failed to write task file", vim.log.levels.ERROR)
                return
            end
            jf:write(encoded)
            jf:close()

            local empty = io.open(tf, "w")
            if empty then empty:write(""); empty:close() end

            M._task_counter = M._task_counter + 1
            local window_name = "pi-" .. M._task_counter

            vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, cur_start_row, 0, {
                id            = start_mark,
                right_gravity = false,
                virt_text     = { { spinner_frames[1] .. " " .. window_name, "AiTaskWorking" } },
                virt_text_pos = "right_align",
            })
            for row = cur_start_row, cur_end_row do
                local hm = vim.api.nvim_buf_set_extmark(source_buf, tracking_nsid, row, 0, {
                    line_hl_group = "AiTaskWorking",
                })
                table.insert(task.highlight_marks, hm)
            end

            local window_id = open_pi_task_pane(window_name)
            if not window_id then return end

            task.window_id   = window_id
            task.window_name = window_name

            -- Spinner animation while Pi is thinking
            local spin = uv.new_timer()
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
            vim.notify("[ai] " .. window_name .. (M.model and (" (" .. M.model .. ")") or ""), vim.log.levels.INFO)

            vim.defer_fn(function()
                if M.model then
                    vim.fn.system(string.format('tmux send-keys -t %q "/model %s" Enter', window_id, M.model))
                    vim.wait(800)
                end
                send_keys_no_focus(window_id, "/nvim-task " .. id, "cmd")
                vim.fn.system(string.format('tmux send-keys -t %q Enter', window_id))
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

        vim.cmd("normal! gg")
end

-- ─────────────────────────────────────────────────────────────────────────────

M.tmux_target = 2

M.agents = {
    copilot = { cmd = "gh copilot", process_pattern = "gh copilot" },
    claude  = { cmd = "claude", process_pattern = "claude" },
    pi      = { cmd = "pi", process_pattern = "pi" },
}

local ok, local_cfg = pcall(require, "local")
M.agent = (ok and local_cfg.agent and M.agents[local_cfg.agent]) or M.agents.copilot

M.queue = {}
M.last_prompt = nil

function M.queue_add(content)
    table.insert(M.queue, content)
end

function M.queue_clear()
    M.queue = {}
end

function M.queue_count()
    return #M.queue
end

local cmp = require("cmp")

local function tmux_available()
    if vim.fn.executable("tmux") ~= 1 then
        vim.notify("tmux not found in PATH", vim.log.levels.ERROR)
        return false
    end
    if not os.getenv("TMUX") then
        vim.notify("Not inside a tmux session", vim.log.levels.ERROR)
        return false
    end
    return true
end

local function send_to_tmux(target, content, buffer_name)
    if not tmux_available() then return end
    if not content or content == "" then return end

    vim.fn.system(string.format('tmux select-window -t %q', target))
    vim.wait(100)

    local temp_file = "/tmp/ai_" .. (buffer_name or "content") .. "_" .. os.time()
    local f = io.open(temp_file, "w")
    if f then
        -- Wrap in bracketed paste escape sequences so the receiving application
        -- treats newlines as literal characters rather than submit keystrokes.
        f:write("\x1b[200~" .. content .. "\x1b[201~")
        f:close()

        local buf_name = "ai_" .. (buffer_name or "content")
        vim.fn.system(string.format('tmux load-buffer -b %q %q', buf_name, temp_file))
        vim.fn.system(string.format('tmux paste-buffer -b %q -t %q', buf_name, target))
        os.remove(temp_file)
    end
end

local function is_agent_running(target)
    if not tmux_available() then return false end

    local pane_pid_cmd = string.format("tmux list-panes -t %q -F '#{pane_pid}'", target)
    local pane_pid = vim.fn.system(pane_pid_cmd):gsub("\n", "")

    if not pane_pid or pane_pid == "" then return false end

    local ps_cmd = string.format("pgrep -P %s -f %s", vim.fn.shellescape(pane_pid),
        vim.fn.shellescape(M.agent.process_pattern))
    local result = vim.fn.system(ps_cmd)

    return result ~= "" and result:find("%d+") ~= nil
end

send_to_existing_session = function(target, prompt)
    send_to_tmux(target, prompt, "prompt")
    vim.wait(250)
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))
end

-- Send to a tmux target without calling select-window (no focus steal)
send_keys_no_focus = function(target, content, buffer_name)
    if not tmux_available() then return end
    if not content or content == "" then return end
    local tf = "/tmp/ai_nf_" .. (buffer_name or "content") .. "_" .. os.time()
    local f = io.open(tf, "w")
    if f then
        f:write("\x1b[200~" .. content .. "\x1b[201~")
        f:close()
        local buf_name = "ai_nf_" .. (buffer_name or "content")
        vim.fn.system(string.format('tmux load-buffer -b %q %q', buf_name, tf))
        vim.fn.system(string.format('tmux paste-buffer -b %q -t %q', buf_name, target))
        os.remove(tf)
    end
end

-- Create a new named tmux window, start Pi in it, return the window ID
open_pi_task_pane = function(window_name)
    if not tmux_available() then return nil end
    -- -d  = don't switch to the new window  -P -F = print the new window's ID
    local window_id = vim.trim(vim.fn.system(
        string.format('tmux new-window -n %q -d -P -F "#{window_id}"', window_name)
    ))
    if window_id == "" then
        vim.notify("[ai] Failed to create tmux window '" .. window_name .. "'", vim.log.levels.ERROR)
        return nil
    end
    -- Start Pi in the new window
    vim.fn.system(string.format('tmux send-keys -t %q %q Enter', window_id, M.agent.cmd))
    return window_id
end

local function send_to_new_session(target, prompt)
    if not tmux_available() then return end

    local cmd = M.agent.cmd
    send_to_tmux(target, cmd, "cmd")
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))

    vim.wait(3000)

    send_to_tmux(target, prompt, "prompt")
    vim.wait(250)
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))
end

M.send_mode = "new"   -- "pane" = existing tmux target, "new" = fresh Pi window per prompt
M.model     = nil     -- nil = Pi's current default; set via <leader>aim or <C-m> in any prompt buffer

function M.toggle_send_mode()
    M.send_mode = M.send_mode == "pane" and "new" or "pane"
    vim.cmd("redrawstatus!")
end

function M.pick_model()
    local raw = vim.fn.system("pi --list-models 2>/dev/null")
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

function M._dispatch_prompt(prompt)
    if M.send_mode == "new" then
        M._task_counter = M._task_counter + 1
        local window_name = "pi-" .. M._task_counter
        local window_id = open_pi_task_pane(window_name)
        if not window_id then return end
        vim.defer_fn(function()
            if M.model then
                vim.fn.system(string.format('tmux send-keys -t %q "/model %s" Enter', window_id, M.model))
                vim.wait(800)
            end
            send_keys_no_focus(window_id, prompt, "prompt")
            vim.fn.system(string.format('tmux send-keys -t %q Enter', window_id))
        end, 3000)
    else
        if is_agent_running(M.tmux_target) then
            send_to_existing_session(M.tmux_target, prompt)
        else
            send_to_new_session(M.tmux_target, prompt)
        end
    end
end

local function get_diagnostic_text()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if #diagnostics > 0 then
        return diagnostics[1].message
    end
    return nil
end

function M.open_prompt_buffer(opts)
    opts = opts or {}

    if not opts.start_line and not opts.end_line and get_diagnostic_text() then
        opts.start_line = vim.fn.line(".")
        opts.end_line = vim.fn.line(".")
    end

    local buf = vim.api.nvim_create_buf(false, true)

    local function make_rel(path)
        if path == "" then
            return nil
        end
        local rel = vim.fn.fnamemodify(path, ":.")
        return rel == path and vim.fn.fnamemodify(path, ":p") or rel
    end

    local curfile = make_rel(vim.fn.expand("%:p"))
    local seen = {}
    if curfile then seen[curfile] = true end
    local others = {}

    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if b.name and b.name ~= "" then
            local rel = make_rel(b.name)
            if rel and not seen[rel] then
                seen[rel] = true
                table.insert(others, rel)
            end
        end
    end

    local lines = {}

    local diagnostic_text = get_diagnostic_text()
    if diagnostic_text then
        table.insert(lines,
            "I have a diagnostic error that I would like you to help me with. Grill me if you are unsure what to do:")
        table.insert(lines, "")
        for diag_line in diagnostic_text:gmatch("[^\n]+") do
            table.insert(lines, "> " .. diag_line)
        end
    else
        table.insert(lines, "")
    end

    table.insert(lines, "")
    table.insert(lines, "Use the /grill-me skill if you are unsure about anything.")
    table.insert(lines, "")
    table.insert(lines, "###### Files in Context:")
    table.insert(lines, "")
    if curfile then
        if opts.start_line and opts.end_line then
            if opts.start_line == opts.end_line then
                table.insert(lines,
                    "- @" .. curfile .. "  <- (this is the current file, line " .. opts.start_line .. " specifically)")
            else
                table.insert(lines,
                    "- @" ..
                    curfile ..
                    "  <- (this is the current file, lines " ..
                    opts.start_line .. "-" .. opts.end_line .. " specifically)")
            end
        else
            table.insert(lines, "- @" .. curfile .. "  <- (this is the current file)")
        end
    end
    for _, f in ipairs(others) do
        table.insert(lines, "- @" .. f)
    end

    table.insert(lines, "")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    vim.cmd("set spell spelllang=en_us")

    cmp.setup.buffer({
        sources = {
            { name = "calc" },
            { name = "luasnip" },
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
        },
    })

    vim.keymap.set("i", "<C-f>", function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        local word_end = col
        local word_start = col

        while word_end < #line and line:sub(word_end + 1, word_end + 1):match("[a-zA-Z0-9_]") do
            word_end = word_end + 1
        end

        while word_start > 0 and line:sub(word_start, word_start):match("[a-zA-Z0-9_]") do
            word_start = word_start - 1
        end

        local word = line:sub(word_start + 1, word_end)
        if word == "" then
            return
        end

        local cwd = vim.fn.getcwd()
        local search_term = word:lower()
        local found_path = nil

        local function scan_dir(dir)
            local handle = vim.loop.fs_scandir(dir)
            if not handle then
                return
            end

            while true do
                local name, type = vim.loop.fs_scandir_next(handle)
                if not name then
                    break
                end

                if type == "directory" and (name == "node_modules" or name == ".git" or name == ".env" or name:sub(1, 1) == ".") then
                    goto continue
                end

                if type == "file" and name:lower():find(search_term, 1, true) then
                    found_path = dir .. "/" .. name
                    return
                elseif type == "directory" and not found_path then
                    scan_dir(dir .. "/" .. name)
                end

                ::continue::
            end
        end

        scan_dir(cwd)

        if found_path then
            local rel_path = found_path:sub(#cwd + 2)
            vim.api.nvim_buf_set_text(0, vim.api.nvim_win_get_cursor(0)[1] - 1, word_start,
                vim.api.nvim_win_get_cursor(0)[1] - 1, word_end, { "@" .. rel_path })
        end
    end, { buffer = buf, noremap = true })

    vim.keymap.set("n", "cc", function()
        local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        if not prompt or prompt == "" then
            return
        end

        M._dispatch_prompt(prompt)

        M.last_prompt = prompt
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Submit prompt to AI agent" })

    vim.cmd("normal! gg")
end

function M.open_add_buffer(opts)
    opts = opts or {}

    if not opts.start_line and not opts.end_line and get_diagnostic_text() then
        opts.start_line = vim.fn.line(".")
        opts.end_line = vim.fn.line(".")
    end

    local buf = vim.api.nvim_create_buf(false, true)

    local function make_rel(path)
        if path == "" then return nil end
        local rel = vim.fn.fnamemodify(path, ":.")
        return rel == path and vim.fn.fnamemodify(path, ":p") or rel
    end

    local curfile = make_rel(vim.fn.expand("%:p"))
    local lines = {}

    -- Heading: file as the title
    if curfile then
        local heading = "### @" .. curfile
        if opts.start_line and opts.end_line then
            if opts.start_line == opts.end_line then
                heading = heading .. " (line " .. opts.start_line .. ")"
            else
                heading = heading .. " (lines " .. opts.start_line .. "-" .. opts.end_line .. ")"
            end
        end
        table.insert(lines, heading)
    end

    table.insert(lines, "")
    table.insert(lines, "")

    local diagnostic_text = get_diagnostic_text()
    if diagnostic_text then
        table.insert(lines,
            "I have a diagnostic error that I would like you to help me with. Grill me if you are unsure what to do:")
        table.insert(lines, "")
        for diag_line in diagnostic_text:gmatch("[^\n]+") do
            table.insert(lines, "> " .. diag_line)
        end
        table.insert(lines, "")
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    vim.cmd("set spell spelllang=en_us")

    cmp.setup.buffer({
        sources = {
            { name = "calc" },
            { name = "luasnip" },
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
        },
    })

    vim.keymap.set("i", "<C-f>", function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        local word_end = col
        local word_start = col

        while word_end < #line and line:sub(word_end + 1, word_end + 1):match("[a-zA-Z0-9_]") do
            word_end = word_end + 1
        end

        while word_start > 0 and line:sub(word_start, word_start):match("[a-zA-Z0-9_]") do
            word_start = word_start - 1
        end

        local word = line:sub(word_start + 1, word_end)
        if word == "" then return end

        local cwd = vim.fn.getcwd()
        local search_term = word:lower()
        local found_path = nil

        local function scan_dir(dir)
            local handle = vim.loop.fs_scandir(dir)
            if not handle then return end
            while true do
                local name, type = vim.loop.fs_scandir_next(handle)
                if not name then break end
                if type == "directory" and (name == "node_modules" or name == ".git" or name == ".env" or name:sub(1, 1) == ".") then
                    goto continue
                end
                if type == "file" and name:lower():find(search_term, 1, true) then
                    found_path = dir .. "/" .. name
                    return
                elseif type == "directory" and not found_path then
                    scan_dir(dir .. "/" .. name)
                end
                ::continue::
            end
        end

        scan_dir(cwd)

        if found_path then
            local rel_path = found_path:sub(#cwd + 2)
            vim.api.nvim_buf_set_text(0, vim.api.nvim_win_get_cursor(0)[1] - 1, word_start,
                vim.api.nvim_win_get_cursor(0)[1] - 1, word_end, { "@" .. rel_path })
        end
    end, { buffer = buf, noremap = true })

    vim.keymap.set("n", "cc", function()
        local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        if not content or content == "" then return end
        M.queue_add(content)
        local count = M.queue_count()
        vim.cmd("bdelete!")
        vim.notify("Added to queue (" .. count .. " item" .. (count == 1 and "" or "s") .. ")", vim.log.levels.INFO)
    end, { buffer = buf, noremap = true, desc = "Add to AI prompt queue" })

    vim.cmd("normal! gg")
    vim.cmd("normal! j")
end

function M.open_review_buffer()
    if M.queue_count() == 0 then
        return M.open_prompt_buffer()
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {}

    table.insert(lines, "")
    table.insert(lines, "Use the /grill-me skill if you are unsure about anything.")
    table.insert(lines, "")
    table.insert(lines, "---")
    table.insert(lines, "")

    for _, item in ipairs(M.queue) do
        for _, line in ipairs(vim.split(item, "\n", { plain = true })) do
            table.insert(lines, line)
        end
        table.insert(lines, "")
        table.insert(lines, "---")
        table.insert(lines, "")
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    vim.cmd("set spell spelllang=en_us")

    cmp.setup.buffer({
        sources = {
            { name = "calc" },
            { name = "luasnip" },
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
        },
    })

    vim.keymap.set("n", "q", function()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Close review buffer without sending" })

    vim.keymap.set("n", "cc", function()
        local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        if not prompt or prompt == "" then return end
        M._dispatch_prompt(prompt)
        M.last_prompt = prompt
        M.queue_clear()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Send queued prompts to AI agent" })

    vim.cmd("normal! gg")
end

function M.restore_prompt()
    if not M.last_prompt or M.last_prompt == "" then
        vim.notify("No prompt to restore", vim.log.levels.WARN)
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(M.last_prompt, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    vim.cmd("set spell spelllang=en_us")

    cmp.setup.buffer({
        sources = {
            { name = "calc" },
            { name = "luasnip" },
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
        },
    })

    vim.keymap.set("n", "cc", function()
        local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        if not prompt or prompt == "" then return end
        M._dispatch_prompt(prompt)
        M.last_prompt = prompt
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Re-send restored prompt to AI agent" })

    vim.keymap.set("n", "q", function()
        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Close restored prompt buffer without sending" })

    vim.cmd("normal! gg")
end

return M

