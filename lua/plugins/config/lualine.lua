local lualine = require("lualine")

local colors = require("cyberdream.colors").default
local codecompanion_spinner = require("plugins.config.lualine.codecompanion-spinner")

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
}

-- Config
local config = {
    options = {
        -- Disable sections and component separators
        component_separators = "",
        section_separators = "",
        theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
    },
    sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
    },
    inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
    },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
end

local function mode_color()
    local mode_to_color = {
        n = colors.magenta,
        i = colors.green,
        v = colors.blue,
        ["␖"] = colors.blue,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        ["␓"] = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.red,
        t = colors.red,
    }
    return { fg = mode_to_color[vim.fn.mode()] }
end

ins_left {
    -- mode component
    function()
        return "▊"
    end,
    color = mode_color,
    padding = { left = 0, right = 1 }, -- We don"t need space before this
}

ins_left({
    codecompanion_spinner,
    color = mode_color,
})

ins_left {
    "filetype",
    icons_enabled = false,
    color = { fg = colors.fg },
}

-- Add components to right sections
ins_left {
    -- LSP server name
    function()
        local msg = "n/a"
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    -- color = { fg = colors.cyan },
}

ins_left {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
}

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it"s any number greater then 2
ins_left {
    function()
        return "%="
    end,
}

ins_right {
    "location",
    color = { fg = colors.fg }
}

ins_right {
    "progress",
    color = { fg = colors.fg }
}

ins_right {
    "o:encoding",
    cond = conditions.hide_in_width,
    color = { fg = colors.green },
}

ins_right {
    -- filesize component
    "filesize",
    cond = conditions.buffer_not_empty,
    color = { fg = colors.yellow },
}

ins_right {
    function()
        return "▊"
    end,
    color = mode_color,
    padding = { left = 1 },
}

-- Now don"t forget to initialize lualine
lualine.setup(config)
