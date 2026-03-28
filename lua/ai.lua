local M = {}

M.tmux_target = 2

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

    local temp_file = "/tmp/copilot_" .. (buffer_name or "content") .. "_" .. os.time()
    local f = io.open(temp_file, "w")
    if f then
        f:write(content)
        f:close()

        local buf_name = "copilot_" .. (buffer_name or "content")
        vim.fn.system(string.format('tmux load-buffer -b %q %q', buf_name, temp_file))
        vim.fn.system(string.format('tmux paste-buffer -b %q -t %q', buf_name, target))
        os.remove(temp_file)
    end
end

local function is_copilot_running(target)
    if not tmux_available() then return false end

    local pane_pid_cmd = string.format("tmux list-panes -t %q -F '#{pane_pid}'", target)
    local pane_pid = vim.fn.system(pane_pid_cmd):gsub("\n", "")

    if not pane_pid or pane_pid == "" then return false end

    local ps_cmd = string.format("pgrep -P %s -f 'gh copilot'", vim.fn.shellescape(pane_pid))
    local result = vim.fn.system(ps_cmd)

    return result ~= "" and result:find("%d+") ~= nil
end

local function send_to_existing_session(target, prompt)
    send_to_tmux(target, prompt, "prompt")
    vim.wait(250)
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))
end

local function send_to_new_session(target, prompt)
    if not tmux_available() then return end

    local cmd = 'gh copilot'
    send_to_tmux(target, cmd, "cmd")
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))

    vim.wait(3000)

    send_to_tmux(target, prompt, "prompt")
    vim.wait(250)
    vim.fn.system(string.format('tmux send-keys -t %q Enter', target))
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

    vim.cmd("botright split")
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

        if is_copilot_running(M.tmux_target) then
            send_to_existing_session(M.tmux_target, prompt)
        else
            send_to_new_session(M.tmux_target, prompt)
        end

        vim.cmd("bdelete!")
    end, { buffer = buf, noremap = true, desc = "Submit prompt to copilot" })

    vim.cmd("normal! gg")
end

return M
