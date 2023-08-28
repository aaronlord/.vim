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
    },
    event = "BufReadPre",
    config = function ()
        local lsp = require("lsp-zero")

        lsp.preset("recommended")

        local cmp = require("cmp")
        local cmp_action = lsp.cmp_action()

        cmp.setup({
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = {
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<Tab>"] = cmp_action.luasnip_supertab(),
                ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
            }, {
                { name = "buffer" },
            })
        })

        lsp.set_preferences({
            suggest_lsp_servers = false,
        })

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

        lsp.on_attach(function(client, bufnr)
            local opts = {buffer = bufnr, remap = false}

            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
            vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
            -- vim.keymap.set("n", "<leader>lws", function() vim.lsp.buf.workspace_symbol() end, opts)
            vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float() end, opts)
            -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
            -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            vim.keymap.set("n", "<leader>lca", function() vim.lsp.buf.code_action() end, opts)
            vim.keymap.set("n", "<leader>lrr", function() vim.lsp.buf.references() end, opts)
            vim.keymap.set("n", "<leader>lrn", function() vim.lsp.buf.rename() end, opts)
            -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

            vim.keymap.set({'n', 'x'}, '<leader>lf', function()
                vim.lsp.buf.format({async = false, timeout_ms = 10000})
            end, opts)
        end)

        lsp.setup()

        vim.diagnostic.config({
            virtual_text = true
        })
    end
} 
