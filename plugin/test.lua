-- A shitty plugin to generate and open tests for Laravel projects

local function find_project_root()
    -- Look for common Laravel project indicators
    local markers = {
        "composer.json",
        "artisan",
        ".git"
    }

    local current_path = vim.fn.expand('%:p:h')
    local path = current_path

    -- Walk up directories until we find a marker or hit root
    while path ~= '/' do
        for _, marker in ipairs(markers) do
            if vim.fn.filereadable(path .. '/' .. marker) == 1 or
                vim.fn.isdirectory(path .. '/' .. marker) == 1 then
                return path
            end
        end
        path = vim.fn.fnamemodify(path, ':h')
    end

    return nil
end

local function get_stub_file(plugin_dir, file_base, class, test_type)
    -- Default stub file
    local stub_file = "test.stub"

    -- Check if stub file exists
    local function stub_exists(stub)
        return vim.fn.filereadable(plugin_dir .. "/stubs/" .. stub) == 1
    end

    -- Get all stub files in the stubs directory
    local stubs_dir = plugin_dir .. "/stubs"
    local stub_files = {}

    if vim.fn.isdirectory(stubs_dir) == 1 then
        -- Get list of files in stubs directory
        local files = vim.fn.globpath(stubs_dir, "*.stub", false, true)
        for _, file in ipairs(files) do
            -- Extract just the filename (without path)
            local filename = vim.fn.fnamemodify(file, ":t")
            table.insert(stub_files, filename)
        end
    end

    -- Determine if we're dealing with a command or query handler
    local is_command_handler = class:match("Handler$") and file_base:find("Commands") ~= nil
    local is_query_handler = class:match("Handler$") and file_base:find("Queries") ~= nil
    local is_model_handler = file_base:find("Models") ~= nil
    local class_lower = class:lower()

    -- First priority: Check for test-type specific command/query handler stubs
    if is_command_handler then
        class_lower = "command-handler"
    elseif is_query_handler then
        class_lower = "query-handler"
    elseif is_model_handler then
        class_lower = "model"
    end

    -- First, check for test type + class suffix specific stubs
    for _, stub in ipairs(stub_files) do
        -- Extract the type from the stub name (between "test.[type]." and ".stub")
        local stub_type = stub:match("test%.(.+)%." .. test_type .. ".stub$")
        if stub_type then
            -- Try to match the class name ending with the stub type
            local type_pattern = stub_type:gsub("%.handler$", "") -- Remove ".handler" if present
            local class_suffix = class_lower:match("(" .. type_pattern .. ")$")

            if class_suffix then
                return stubs_dir .. "/" .. stub
            end
        end
    end

    -- Second, check class name suffixes against available stubs (without test type)
    for _, stub in ipairs(stub_files) do
        -- Extract the type from the stub name (between "test." and ".stub")
        local stub_type = stub:match("test%.(.+)%.stub$")
        if stub_type and not stub:match("test%." .. test_type) then -- Skip test-type specific ones we already checked
            -- Try to match the class name ending with the stub type
            local type_pattern = stub_type:gsub("%.handler$", "")   -- Remove ".handler" if present
            local class_suffix = class_lower:match("(" .. type_pattern .. ")$")

            if class_suffix then
                return stubs_dir .. "/" .. stub
            end
        end
    end

    -- Return the test-type specific stub if it exists
    local test_type_stub = "test." .. test_type .. ".stub"
    if stub_exists(test_type_stub) then
        return stubs_dir .. "/" .. test_type_stub
    end

    -- Return the default stub path if it exists
    if stub_exists(stub_file) then
        return stubs_dir .. "/" .. stub_file
    end

    -- As a last resort, use the first stub file found
    if #stub_files > 0 then
        return stubs_dir .. "/" .. stub_files[1]
    end

    -- If no stubs found, return an error
    error("No stub files found in " .. stubs_dir)
end

local function extract_public_methods(file_path)
    -- Read the PHP file
    local content = table.concat(vim.fn.readfile(file_path), "\n")
    local methods = {}

    -- Pattern to match public function declarations in PHP
    -- This handles various spacing conventions and optional return type declarations
    for method_name in string.gmatch(content, "public%s+function%s+([%w_]+)%s*%(") do
        -- Skip constructor and common magic methods
        if method_name ~= "__construct" and
            method_name ~= "__destruct" and
            method_name ~= "__toString" and
            method_name ~= "__get" and
            method_name ~= "__set" then
            table.insert(methods, method_name)
        end
    end

    return methods
end

local function generate_describes_content(plugin_dir, methods, class)
    if type(methods) ~= "table" then
        methods = {}
    end

    -- Check if describe stub exists
    local describe_stub_path = plugin_dir .. "/stubs/test.describe.stub"

    if vim.fn.filereadable(describe_stub_path) ~= 1 then
        print("Warning: test.describe.stub not found at path: " .. describe_stub_path)
        return ""
    end

    -- Read the describe stub template
    local describe_stub_content = vim.fn.readfile(describe_stub_path)
    local describe_stub = table.concat(describe_stub_content, "\n")

    if #methods == 0 then
        -- No methods found, use a default method name
        local stub = describe_stub:gsub("{{ method }}", "method")
        -- Also replace {{ class }} with the actual class name
        stub = stub:gsub("{{ class }}", class)
        return stub
    end

    -- Build the describes string with proper formatting using string concatenation
    local result = ""
    for i, method in ipairs(methods) do
        if i > 1 then
            result = result .. "\n\n"
        end

        -- Replace both {{ method }} and {{ class }} placeholders
        local method_stub = describe_stub:gsub("{{ method }}", method)
        method_stub = method_stub:gsub("{{ class }}", class)
        result = result .. method_stub
    end

    return result
end

local function open_test(test_type)
    local current_file = vim.fn.expand('%:p'):gsub("^/+", "/") -- Normalize leading slashes
    local project_root = find_project_root():gsub("^/+", "/")  -- Normalize leading slashes

    if not project_root then
        vim.api.nvim_err_writeln("Could not find project root")
        return
    end

    -- Use string.find instead of pattern matching for more reliable path checking
    if not current_file:find(project_root .. "/app/", 1, true) then
        vim.api.nvim_err_writeln("Current file is not in app/ directory")
        print("Expected path: " .. project_root .. "/app/")
        return
    end

    -- Extract the path relative to app/ directory
    local app_dir = project_root .. "/app/"
    local relative_path = current_file:sub(app_dir:len() + 1)

    if not relative_path or relative_path == "" then
        vim.api.nvim_err_writeln("Could not determine file path")
        return
    end

    -- Remove .php extension if present
    local file_base = relative_path:gsub("%.php$", "")

    -- Convert path separators to namespace separators
    local namespace = file_base:gsub("/", "\\")

    -- Figure out the fully qualified class name
    local fully_qualified_class = "App\\" .. namespace

    -- Get class name (last part of the namespace)
    local class = namespace:match("([^\\]+)$")
    if not class then
        vim.api.nvim_err_writeln("Could not determine class name")
        return
    end

    -- Extract public methods from the PHP class
    local methods = extract_public_methods(current_file)

    -- Build test file path
    local test_dir = string.format("%s/tests/%s", project_root, test_type:sub(1, 1):upper() .. test_type:sub(2))
    local test_file_path = string.format("%s/%sTest.php", test_dir, file_base:gsub("/", "/"))

    -- Check if test file exists
    if vim.fn.filereadable(test_file_path) == 1 then
        -- Open existing test file
        vim.cmd("edit " .. test_file_path)
    else
        -- Get the directory where this plugin file is located
        local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h")

        -- Determine which stub file to use based on class name and file path
        local stub_path = get_stub_file(plugin_dir, file_base, class, test_type)

        local stub_content = vim.fn.readfile(stub_path)

        -- Calculate the test namespace
        local test_namespace = "Tests\\" ..
            test_type:sub(1, 1):upper() .. test_type:sub(2) .. "\\" .. namespace:gsub("\\" .. class .. "$", "")

        -- Generate describes content based on methods
        local describes_content = ""
        if vim.fn.filereadable(plugin_dir .. "/stubs/test.describe.stub") == 1 then
            describes_content = generate_describes_content(plugin_dir, methods, class)
        end

        -- Replace placeholders in stub
        local processed_content = {}
        for _, line in ipairs(stub_content) do
            if line:find("{{ describes }}") then
                -- Special handling for describes placeholder - split it into separate lines
                if describes_content ~= "" then
                    -- Split the describes content into individual lines and add each one
                    for _, describe_line in ipairs(vim.split(describes_content, "\n", true)) do
                        table.insert(processed_content, describe_line)
                    end
                else
                    -- Keep the original line if no describes content
                    table.insert(processed_content, line)
                end
            else
                -- Normal placeholder replacement
                line = line:gsub("{{ namespace }}", test_namespace)
                line = line:gsub("{{ fully_qualified_class }}", fully_qualified_class)
                line = line:gsub("{{ class }}", class)
                table.insert(processed_content, line)
            end
        end


        -- Ask for confirmation before creating the file using the stub
        local confirm_msg = string.format(
            "Create %s from %s?",
            test_file_path:sub(project_root:len() + 2),
            stub_path:match("([^/\\]+)$")
        )

        vim.api.nvim_out_write(confirm_msg .. "\n")
        local key = vim.fn.getchar()
        -- 13 is Enter, 27 is ESC
        if key ~= 13 then
            return
        end

        -- Create directories if they don't exist
        local test_file_dir = vim.fn.fnamemodify(test_file_path, ":h")
        if vim.fn.isdirectory(test_file_dir) == 0 then
            vim.fn.mkdir(test_file_dir, "p")
        end

        -- Write the new test file
        vim.fn.writefile(processed_content, test_file_path)

        -- Open the new test file
        vim.cmd("edit " .. test_file_path)
    end
end

vim.api.nvim_create_user_command('Test', function(opts)
    local arg = opts.args:lower()

    local type_map = {
        feature = "feature",
        feat = "feature",
        f = "feature",
        unit = "unit",
        u = "unit",
    }

    local test_type = type_map[arg]

    if not test_type then
        vim.api.nvim_err_writeln("Usage: :Test <feature|unit>")
        return
    end

    open_test(test_type)
end, {
    nargs = 1,
    complete = function()
        return { "feature", "feat", "f", "unit", "u" }
    end,
})

-- Create filetype-specific mappings for PHP files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
        -- Map <leader>tu to run :Test unit
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tu', ':Test unit<CR>', {
            noremap = true,
            silent = true,
            desc = "Generate/Open unit test for current file"
        })

        -- Map <leader>tf to run :Test feature
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tf', ':Test feature<CR>', {
            noremap = true,
            silent = true,
            desc = "Generate/Open feature test for current file"
        })
    end
})

local tmux_target = "2"

local function run_test()
    local current_file = vim.fn.expand('%:p'):gsub("^/+", "/") -- Normalize leading slashes
    local project_root = find_project_root():gsub("^/+", "/")  -- Normalize leading slashes

    if not project_root then
        vim.api.nvim_err_writeln("Could not find project root")
        return
    end

    local relative_path = current_file:sub(project_root:len() + 2)

    local cmd = string.format("tmux send-keys -t %s 'magnus pest %s' C-m", tmux_target, relative_path)

    vim.fn.system(cmd)
end


local function open_or_create_test_for_current_file()
    local current_file = vim.fn.expand('%:p'):gsub("^/+", "/")
    local project_root = find_project_root()
    if not project_root then
        vim.api.nvim_err_writeln("Could not find project root")
        return
    end

    -- Check if current file is a test file
    if current_file:find("/tests") then
        run_test()
        return
    end

    -- Try to open Unit test first, then Feature test
    local app_dir = project_root .. "/app/"
    local relative_path = current_file:sub(app_dir:len() + 1):gsub("%.php$", "")
    local unit_test_path = string.format("%s/tests/Unit/%sTest.php", project_root, relative_path)
    local feature_test_path = string.format("%s/tests/Feature/%sTest.php", project_root, relative_path)

    if vim.fn.filereadable(unit_test_path) == 1 then
        vim.cmd("edit " .. unit_test_path)
        return
    elseif vim.fn.filereadable(feature_test_path) == 1 then
        vim.cmd("edit " .. feature_test_path)
        return
    else
        -- Generate Unit test if neither exists
        open_test("unit")
    end
end

vim.keymap.set('n', '<leader>tt', open_or_create_test_for_current_file, {
    noremap = true,
    silent = true,
    desc = "Open or generate test file for current file, or run test if already in test file"
})

return {}
