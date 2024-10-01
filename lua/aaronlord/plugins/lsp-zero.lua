return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
        lazy = true,
        config = false,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-buffer' },
            { "onsails/lspkind.nvim" },
        },
        config = function()
            local cmp = require('cmp')
            local cmp_action = require('lsp-zero').cmp_action()

            require("luasnip.loaders.from_snipmate").lazy_load()

            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ['<Tab>'] = cmp_action.luasnip_supertab(),
                    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
                }),
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                formatting = {
                    fields = { 'abbr', 'kind', 'menu' },
                    format = require('lspkind').cmp_format({
                        mode = 'symbol',       -- show only symbol annotations
                        maxwidth = 50,         -- prevent the popup from showing more than provided characters
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
                    })
                },
            })
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
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

            local lsp_zero = require('lsp-zero')

            -- lsp_attach is where you enable features that only work
            -- if there is a language server active in the file
            local lsp_attach = function(client, bufnr)
                local opts = { buffer = bufnr }

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
                -- vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = false, timeout_ms = 10000 }) end, opts)
                vim.keymap.set("n", "<F4>", function() vim.lsp.buf.code_action() end, opts)
            end

            lsp_zero.extend_lspconfig({
                sign_text = true,
                lsp_attach = lsp_attach,
                capabilities = require('cmp_nvim_lsp').default_capabilities()
            })

            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                }
            })
        end
    }
}
