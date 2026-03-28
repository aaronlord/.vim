vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")

local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "calc" },
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
    },
    window = {
        completion = cmp.config.window.bordered({
            border = "rounded",
        }),
        documentation = cmp.config.window.bordered({
            border = "rounded",
        }),
    },
    mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm({
                behavior = cmp.SelectBehavior.InsertEnter,
                select = true,
            }),
            { "i", "c" }
        ),
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    formatting = {
        fields = { "abbr", "kind", "menu" },
        format = require("lspkind").cmp_format({
            mode = "symbol",
            maxwidth = 150,
            ellipsis_char = "...",
        })
    },
})

local ls = require("luasnip")

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
})

for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("snippets/*.lua", true)) do
    loadfile(ft_path)()
end

vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end)

vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end)

vim.keymap.set({ "i", "s" }, "<C-l>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

vim.keymap.set({ "i", "s" }, "<C-;>", function()
    require("luasnip.extras.select_choice")()
end)

-- Insert full path with @ prefix for the word under cursor
vim.keymap.set("i", "<C-f>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    
    -- Find word boundaries
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

    -- Recursively find file matching word
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

            -- Skip common directories
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
        -- Remove cwd prefix to get relative path
        local rel_path = found_path:sub(#cwd + 2)
        -- Replace word with @path
        vim.api.nvim_buf_set_text(0, vim.api.nvim_win_get_cursor(0)[1] - 1, word_start, vim.api.nvim_win_get_cursor(0)[1] - 1, word_end, { "@" .. rel_path })
    end
end)
