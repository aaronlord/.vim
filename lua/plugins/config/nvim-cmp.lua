vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")

local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
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
local types = require("luasnip.util.types")

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "⌥", "Error" } },
            }
        }
    }
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
