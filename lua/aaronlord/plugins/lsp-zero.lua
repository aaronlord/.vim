return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
        -- LSP Support
        { "neovim/nvim-lspconfig" },
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },

        -- Autocompletion
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "L3MON4D3/LuaSnip" },
        { "saadparwaiz1/cmp_luasnip" },
        { "onsails/lspkind.nvim" },

        -- Lint
        { "mfussenegger/nvim-lint" },

        -- UI
        { "j-hui/fidget.nvim" }
    },
    event = "BufReadPre",
    config = function ()
        local lsp = require("lsp-zero")

        lsp.preset("recommended")

        lsp.set_preferences({
            suggest_lsp_servers = false,
        })

        lsp.on_attach(function(client, bufnr)
            local opts = {buffer = bufnr, remap = false}

            vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
            vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
            vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, opts)
            vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
            vim.keymap.set('n', 'go', function() vim.lsp.buf.type_definition() end, opts)
            vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, opts)
            vim.keymap.set('n', 'gs', function() vim.lsp.buf.signature_help() end, opts)
            vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, opts)
            vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
            vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            vim.keymap.set("n", "<F2>", function() vim.lsp.buf.rename() end, opts)
            vim.keymap.set({'n', 'x'}, '<F3>', function() vim.lsp.buf.format({async = false, timeout_ms = 10000}) end, opts)
            vim.keymap.set("n", "<F4>", function() vim.lsp.buf.code_action() end, opts)
        end)

        local signs = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = ""
        }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type

            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        vim.diagnostic.config({
            virtual_text = true,
            underline = false,
        })

        lsp.setup()

        local cmp = require("cmp")
        local cmp_action = lsp.cmp_action()

        cmp.setup({
            --[[
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            ]]--
            window = {
                completion = {
                    border = "rounded",
                    -- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    col_offset = -4,
                    side_padding = 0,
                },
                documentation = {
                    border = "rounded",
                    -- winhighlight = "Normal:FloatBorder:Pmenu,Search:None",
                    side_padding = 0,
                }
            },
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    local kind = require("lspkind").cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50
                    })(entry, vim_item)

                    local strings = vim.split(kind.kind, "%s", {
                        trimempty = true
                    })

                    kind.kind = " " .. (strings[1] or "") .. " "
                    kind.menu = "    " .. (strings[2]:lower() or "")

                    return kind
                end,
            },
            mapping = {
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<Tab>"] = cmp_action.luasnip_supertab(),
                ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
        })

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                require("lint").try_lint(nil, {
                    ignore_errors = true
                })
            end,
        })

        require("luasnip.loaders.from_snipmate").lazy_load()

        require("fidget").setup()
    end
}
