-- UI improvements for nvim's built-in LSP
vim.diagnostic.config({
    virtual_text = false, -- using tiny-inline-diagnostic instead
    underline = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
        }
    },
})

vim.lsp.enable('vtsls')

-- Explicit vim.lsp.config() calls have highest priority and override nvim-lspconfig's
-- lsp/*.lua defaults (which load from runtimepath and would otherwise win since plugins
-- are later in rtp — their filetypes list, without 'vue', would silently override ours).
local vue_language_server_path = vim.fn.expand '$MASON/packages'
    .. '/vue-language-server'
    .. '/node_modules/@vue/language-server'

vim.lsp.config('vtsls', {
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    {
                        name = '@vue/typescript-plugin',
                        location = vue_language_server_path,
                        languages = { 'vue' },
                        configNamespace = 'typescript',
                    },
                },
            },
        },
    },
    filetypes = {
        'typescript',
        'javascript',
        'javascriptreact',
        'typescriptreact',
        'vue',
    },
})

-- Start vue_ls only AFTER vtsls has attached so hybrid mode can find the TS server
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('vue_split_server', { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not (client and client.name == 'vtsls') then return end
        if vim.bo[args.buf].filetype ~= 'vue' then return end
        vim.lsp.start(vim.lsp.config['vue_ls'], { bufnr = args.buf })
    end,
})
