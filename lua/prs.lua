local M = {}

local function get_first_commit_message()
    local handle = io.popen("git log -1 --pretty=%B 2>/dev/null", 'r')
    if not handle then
        return ""
    end
    local message = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()
    return message or ""
end

local function get_current_branch()
    local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null", 'r')
    if not handle then
        return ""
    end
    local branch = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()
    return branch or ""
end

local function read_template()
    local template_path = ".github/pull_request_template.md"
    local file = io.open(template_path, "r")
    if not file then
        return ""
    end
    local content = file:read("*a")
    file:close()

    local branch = get_current_branch()
    local ticket_match = branch:match("([A-Z]+-[0-9]+)")

    if ticket_match then
        content = content:gsub("https://veracross%.atlassian%.net/browse/MNG%-0",
            "https://veracross.atlassian.net/browse/" .. ticket_match)
    else
        content = content:gsub("https://veracross%.atlassian%.net/browse/MNG%-0", "_n/a_")
    end

    local checkboxes_to_check = {
        "Assign yourself to this PR",
        "Implement application code",
        "Write a concise PR title if squashing, or clean your commits if rebasing"
    }

    for _, checkbox_text in ipairs(checkboxes_to_check) do
        content = content:gsub("%-%s*%[%s*%]%s+" .. vim.pesc(checkbox_text),
            "- [x] " .. checkbox_text)
    end

    return content
end

local function extract_json_string(json_str, key)
    local pattern = '"' .. key .. '"%s*:%s*"(.-[^\\])"'
    local match = json_str:match(pattern)
    if match then
        match = match:gsub('\\"', '"')
        match = match:gsub('\\n', '\n')
        match = match:gsub('\\r', '\r')
        match = match:gsub('\\t', '\t')
        match = match:gsub('\\/', '/')
        match = match:gsub('\\\\', '\\')
        return match
    end
    return nil
end

local function decode_html_entities(str)
    local html_entities = {
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&amp;"] = "&",
        ["&quot;"] = '"',
        ["&apos;"] = "'",
        ["&nbsp;"] = " ",
        ["&copy;"] = "©",
        ["&reg;"] = "®",
        ["&deg;"] = "°",
        ["&frasl;"] = "/",
        ["&larr;"] = "←",
        ["&rarr;"] = "→",
        ["&uarr;"] = "↑",
        ["&darr;"] = "↓",
        ["&lsquo;"] = "'",
        ["&rsquo;"] = "'",
        ["&ldquo;"] = '"',
        ["&rdquo;"] = '"',
        ["\\u003c"] = "<",
        ["\\u003e"] = ">",
        ["\\u0026"] = "&",
        ["\\'"] = "'",
        ['\\"'] = '"',
    }

    local result = str
    for entity, char in pairs(html_entities) do
        result = result:gsub(entity, char)
    end

    return result
end

local function get_current_pr()
    local handle = io.popen("gh pr view --json number --template '{{.number}}' 2>/dev/null", 'r')
    if not handle then
        return nil
    end
    local pr_number = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()
    if pr_number == "" then
        return nil
    end
    return pr_number
end

M.create = function()
    vim.notify("Pushing branch...", vim.log.levels.INFO)
    vim.fn.system("git push")
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to push branch", vim.log.levels.ERROR)
        return
    end

    vim.notify("Checking for existing PR...", vim.log.levels.INFO)
    local url_handle = io.popen("gh pr view --json url --template '{{.url}}' 2>/dev/null", 'r')

    if url_handle then
        local existing_url = url_handle:read("*a"):match("^%s*(.-)%s*$")
        url_handle:close()

        if existing_url ~= "" then
            vim.fn.setreg("+", existing_url)
            vim.notify(existing_url .. " (exists, copied to clipboard)", vim.log.levels.INFO)
            return
        end
    end

    vim.notify("Getting commit message...", vim.log.levels.INFO)
    local default_title = get_first_commit_message()

    vim.ui.input({ prompt = "PR Title: ", default = default_title }, function(input)
        local title = input or ""

        if title == "" then
            vim.notify("PR title cannot be empty", vim.log.levels.WARN)
            return
        end

        local template = read_template()

        local bufnr = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(template, "\n"))
        vim.api.nvim_set_current_buf(bufnr)
        vim.bo[bufnr].filetype = "markdown"

        vim.notify("Press 'cc' to submit PR as draft", vim.log.levels.INFO)

        local function submit_pr()
            local body_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local body = table.concat(body_lines, "\n")

            vim.api.nvim_buf_delete(bufnr, { force = true })

            local cmd = string.format(
                "gh pr create --draft --title %s --body %s --assignee @me",
                vim.fn.shellescape(title),
                vim.fn.shellescape(body)
            )

            local handle = io.popen(cmd .. " 2>&1", 'r')
            if not handle then
                vim.notify("Failed to create PR", vim.log.levels.ERROR)
                return
            end

            local output = handle:read("*a")
            handle:close()

            local pr_url = output:match("https://github%.com/[^\n%s]+")

            if pr_url then
                vim.fn.setreg("+", pr_url)
                vim.notify(pr_url .. " (copied to clipboard)", vim.log.levels.INFO)
            else
                if output:find("already exists") then
                    local existing_handle = io.popen("gh pr view --json url --template '{{.url}}' 2>/dev/null", 'r')
                    if existing_handle then
                        local existing_url = existing_handle:read("*a"):match("^%s*(.-)%s*$")
                        existing_handle:close()
                        if existing_url ~= "" then
                            vim.fn.setreg("+", existing_url)
                            vim.notify(existing_url .. " (PR already exists, copied to clipboard)",
                                vim.log.levels.INFO)
                            return
                        end
                    end
                end
                vim.notify("PR creation output:\n" .. output, vim.log.levels.WARN)
            end
        end

        vim.keymap.set("n", "cc", submit_pr, { buffer = bufnr, noremap = true })
        vim.notify("Press 'cc' to submit PR as draft", vim.log.levels.INFO)
    end)
end

M.ready = function()
    local pr_number = get_current_pr()
    if not pr_number then
        vim.notify("Could not find PR for current branch", vim.log.levels.ERROR)
        return
    end

    vim.fn.system(string.format("gh pr ready %s", pr_number))
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to mark PR as ready", vim.log.levels.ERROR)
        return
    end

    vim.fn.system(string.format("gh pr merge %s --squash --auto", pr_number))
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to enable auto merge", vim.log.levels.ERROR)
        return
    end

    vim.notify("PR #" .. pr_number .. " marked ready and set to auto merge (squash)", vim.log.levels.INFO)
end

M.draft = function()
    vim.notify("Finding PR for current branch...", vim.log.levels.INFO)

    local pr_number = get_current_pr()
    if not pr_number then
        vim.notify("Could not find PR for current branch", vim.log.levels.ERROR)
        return
    end

    vim.notify("Marking PR #" .. pr_number .. " as draft...", vim.log.levels.INFO)

    vim.fn.system(string.format("gh pr ready %s --undo", pr_number))
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to mark PR as draft", vim.log.levels.ERROR)
        return
    end

    vim.notify("PR #" .. pr_number .. " marked as draft", vim.log.levels.INFO)
end

M.view = function()
    vim.notify("Getting PR URL...", vim.log.levels.INFO)
    local handle = io.popen("gh pr view --json url --template '{{.url}}' 2>/dev/null", 'r')

    if not handle then
        vim.notify("Could not find PR for current branch", vim.log.levels.ERROR)
        return
    end

    local pr_url = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()

    if pr_url == "" then
        vim.notify("Could not find PR for current branch", vim.log.levels.ERROR)
        return
    end

    vim.notify("Opening PR in browser...", vim.log.levels.INFO)
    vim.fn.system(string.format("open '%s'", pr_url))
    vim.notify("Opened: " .. pr_url, vim.log.levels.INFO)
end

M.commented_files = function()
    vim.notify("Fetching files with comments...", vim.log.levels.INFO)

    local pr_number = get_current_pr()
    if not pr_number then
        vim.notify("Could not find PR for current branch", vim.log.levels.ERROR)
        return
    end

    local repo_handle = io.popen("gh repo view --json nameWithOwner --template '{{.nameWithOwner}}' 2>/dev/null", 'r')
    if not repo_handle then
        vim.notify("Could not determine repository", vim.log.levels.ERROR)
        return
    end

    local repo = repo_handle:read("*a"):match("^%s*(.-)%s*$")
    repo_handle:close()

    local handle = io.popen(
        string.format(
            "gh api repos/%s/pulls/%s/comments -q '.[] | {path: .path, line: (.line // 0), body: .body}'",
            repo, pr_number),
        'r')

    if not handle then
        vim.notify("Could not fetch PR comments", vim.log.levels.ERROR)
        return
    end

    local files_data = {}
    local quicklist_items = {}

    for line in handle:lines() do
        if line ~= "" and line:match("^%s*{") then
            local path_match = extract_json_string(line, "path")
            local line_match = line:match('"line"%s*:%s*(%d+)')
            local body_match = extract_json_string(line, "body")

            if path_match then
                local filepath = path_match
                local line_num = tonumber(line_match)
                local comment_text = decode_html_entities(body_match or "")

                if line_num == 0 then
                    goto continue
                end

                if not files_data[filepath] then
                    files_data[filepath] = {}
                end

                table.insert(files_data[filepath], { line = line_num, text = comment_text })

                if line_num and line_num > 0 then
                    local comment_preview = comment_text:gsub("\n", " ")

                    table.insert(quicklist_items, {
                        filename = filepath,
                        lnum = line_num,
                        col = 1,
                        text = comment_preview
                    })
                end

                ::continue::
            end
        end
    end
    handle:close()

    if vim.tbl_isempty(files_data) then
        vim.notify("No files with comments found", vim.log.levels.INFO)
        return
    end

    vim.fn.setqflist(quicklist_items)
    vim.cmd("copen")

    local ns_id = vim.api.nvim_create_namespace("pr_comments")

    for filepath, comments in pairs(files_data) do
        local bufnr = vim.fn.bufnr(filepath)
        if bufnr == -1 then
            bufnr = vim.fn.bufadd(filepath)
        end

        local diagnostics = {}
        for _, comment in ipairs(comments) do
            local line_num = comment.line > 0 and (comment.line - 1) or 0
            table.insert(diagnostics, {
                lnum = line_num,
                col = 0,
                end_lnum = line_num,
                end_col = 0,
                severity = vim.diagnostic.severity.INFO,
                message = comment.text,
                source = "PR Comment",
            })
        end

        vim.diagnostic.set(ns_id, bufnr, diagnostics)
    end

    vim.notify("Loaded " .. vim.tbl_count(files_data) .. " files with comments", vim.log.levels.INFO)
end

return M
