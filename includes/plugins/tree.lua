local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.6

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
    sort_by = 'case_sensitive',
    hijack_cursor = true,
    system_open = {
        cmd = 'open',
    },
    view = {
        float = {
            enable = true,
            open_win_config = function()
                local screen_w = vim.opt.columns:get()
                local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
                local window_w = screen_w * WIDTH_RATIO
                local window_h = screen_h * HEIGHT_RATIO
                local window_w_int = math.floor(window_w)
                local window_h_int = math.floor(window_h)
                local center_x = (screen_w - window_w) / 2
                local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

                return {
                    border = 'solid',
                    relative = 'editor',
                    style = 'minimal',
                    row = center_y,
                    col = center_x,
                    width = window_w_int,
                    height = window_h_int,
                }
            end,
        },
        width = function()
            return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
        end,
    },
    renderer = {
        group_empty = true,
        icons = {
            show = {
                git = false,
                file = true,
                folder = false,
                folder_arrow = true,
            },
            glyphs = {
                bookmark = '🔖',
                folder = {
                    arrow_closed = '⏵',
                    arrow_open = '⏷',
                }
            },
        },
    },
    git = {
        ignore = false
    },
    filters = {
        dotfiles = false,
        custom = {
            '^.git$',
            '^.phplint.cache$',
            '^.phpunit.result.cache$',
            '^.undodir$',
        }
    },
})

vim.keymap.set('n', '<c-k><c-b>', ':NvimTreeFocus<cr>', {noremap = true, silent = true})
vim.keymap.set('n', '<c-k><c-f>', ':NvimTreeFindFile<cr>', {noremap = true, silent = true})
